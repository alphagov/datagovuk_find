module Search
  class Query
    MULTI_MATCH_FIELDS = %w(title summary description location*^2)
    MULTI_MATCH_FIELDS_ENGLISH = %w(title.english^2 summary.english description.english)
    TERMS_SIZE = 10_000

    attr_accessor :clauses

    def initialize(*clauses)
      self.clauses = clauses.flatten
    end

    def to_elasticsearch
      query = { query: { bool: {} } }

      if clauses.any?
        query[:query][:bool][:must] = clauses.map do |clause|
          clause_to_query(clause)
        end
      end

      query
    end

    def self.publishers_aggregation
      {
        size: 0,
        aggs: {
          organisations: {
            nested: {
              path: 'organisation'
            },
            aggs: {
              org_titles: {
                terms: {
                  field: 'organisation.title.raw',
                  order: {_term: 'asc'},
                  size: TERMS_SIZE
                }
              }
            }
          }
        }
      }
    end

    def self.datafiles_aggregation
      {
        size: 0,
        aggs: {
          datafiles: {
            nested: {
              path: 'datafiles'
            },
            aggs: {
              datasets_with_datafiles: {
                reverse_nested: {}
              },
              formats: {
                terms: {
                  field: 'datafiles.format'
                }
              }
            }
          }
        }
      }
    end

    def self.locations_aggregation
      {
        size: 0,
        aggs: {
          locations: {
            terms: {
              field: 'location1.raw',
              size: TERMS_SIZE
            }
          }
        }
      }
    end

    def self.dataset_topics_aggregation
      {
        size: 0,
        aggs: {
          topics: {
            nested: {
              path: 'topic'
            },
            aggs: {
              topic_titles: {
                terms: {
                  field: 'topic.title.raw',
                  order: { _term: 'asc' },
                  size: TERMS_SIZE
                }
              }
            }
          }
        }
      }
    end

    def self.datafile_formats_aggregation
      {
        size: 0,
        aggs: {
          datafiles: {
            nested: {
              path: 'datafiles'
            },
            aggs: {
              datafile_formats: {
                terms: {
                  field: 'datafiles.format'
                }
              }
            }
          }
        }
      }
    end

    def self.related(id)
      {
        size: 4,
        query: {
          dis_max: {
            queries: [
              {
                more_like_this: {
                  fields: %w(title summary description),
                  like: {
                    _type: "dataset",
                    _id: id
                  },
                  min_term_freq: 1,
                  min_doc_freq: 1
                }
              },
              {
                more_like_this: {
                  fields: %w(organisation^2 location*^2),
                  like: {
                    _type: "dataset",
                    _id: id
                  },
                  boost: 20,
                  min_term_freq: 1,
                  min_doc_freq: 1
                }
              }
            ]
          }
        }
      }
    end

    def self.search(params)
      query_param = params.fetch('q', '').squish
      sort_param =  params['sort']

      publisher_param = params.dig(:filters, :publisher)
      location_param =  params.dig(:filters, :location)
      format_param =    params.dig(:filters, :format)
      topic_param =    params.dig(:filters, :topic)
      licence_param =   params.dig(:filters, :licence)

      query = begin
        QueryTransformer.new.apply(QueryParser.new.parse(query_param))
      rescue Parslet::ParseFailed
        Query.new(TermsClause.new(query_param))
      end

      query = query.to_elasticsearch

      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << publisher_filter(publisher_param) if publisher_param.present?
      query[:query][:bool][:must] << location_filter(location_param)   if location_param.present?
      query[:query][:bool][:must] << topic_filter(topic_param)         if topic_param.present?
      query[:query][:bool][:must] << format_filter(format_param)       if format_param.present?
      query[:query][:bool][:must] << licence_filter(licence_param)     if licence_param.present?

      # If we have a must clause then a dataset will match the bool query even
      # if none of the should queries match. If the must clause is empty at
      # least one of the should queries must match a dataset for it to match
      # the bool query. Therefore we can only include the should clause if we
      # have a must clause also set otherwise we'll only get datasets we boost.
      if query[:query][:bool][:must].any?
        query[:query][:bool][:should] ||= []
        query[:query][:bool][:should] << organisation_title_filter(query_param, boost: 1)
        query[:query][:bool][:should] << organisation_category_filter('ministerial-department', boost: 2)
        query[:query][:bool][:should] << organisation_category_filter('non-ministerial-department', boost: 2)
        query[:query][:bool][:should] << organisation_category_filter('executive-ndpb', boost: 2)
        query[:query][:bool][:should] << organisation_category_filter('local-council', boost: 1)
      end

      query[:sort] = { "last_updated_at": { "order": "desc" } } if sort_param == "recent"

      query
    end

    def self.by_legacy_name(legacy_name)
      {
        query: {
          constant_score: {
            filter: {
              term: { legacy_name: legacy_name }
            }
          }
        }
      }
    end

    def self.by_uuid(uuid)
      {
        query: {
          constant_score: {
            filter: {
              term: { uuid: uuid }
            }
          }
        }
      }
    end

    def self.publisher_filter(publisher)
      {
        nested: {
          path: "organisation",
          query: {
            bool: {
              must: [
                {
                  match: {
                    "organisation.title.raw": publisher
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.topic_filter(topic)
      {
        nested: {
          path: "topic",
          query: {
            bool: {
              must: [
                {
                  match: {
                    "topic.title.raw": topic
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.format_filter(format)
      {
        nested: {
          path: "datafiles",
          query: {
            bool: {
              must: [
                {
                  match: {
                    "datafiles.format": format
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.location_filter(location)
      {
        match: {
          "location1": location
        }
      }
    end

    def self.licence_filter(licence)
      {
        match: {
          "licence": licence
        }
      }
    end

    def self.organisation_category_filter(organisation_category, boost: 2)
      {
        nested: {
          path: 'organisation',
          query: {
            term: {
              'organisation.category.keyword' => {
                value: organisation_category,
                boost: boost
              }
            }
          }
        }
      }
    end

    def self.organisation_title_filter(organisation_title, boost: 2)
      {
        nested: {
          path: 'organisation',
          query: {
            match: {
              "organisation.title.english" => {
                query: organisation_title,
                analyzer: 'english',
                boost: boost,
              },
            },
          },
        },
      }
    end

    private_class_method :publisher_filter, :topic_filter, :location_filter, :format_filter, :licence_filter

    private

    def clause_to_query(clause)
      case clause
      when TermsClause
        multi_match(clause.terms)
      when PhraseClause
        multi_match_phrase(clause.phrase)
      else
        raise Error, "Unknown clause type: #{clause}"
      end
    end

    def multi_match(terms)
      {
        multi_match: {
          query: terms,
          fields: MULTI_MATCH_FIELDS_ENGLISH,
          analyzer: 'english',
        }
      }
    end

    def multi_match_phrase(phrase)
      {
        multi_match: {
          query: phrase,
          type: 'phrase',
          fields: MULTI_MATCH_FIELDS,
        }
      }
    end
  end
end
