module Search
  class Query
    TERMS_SIZE = 10_000

    def self.publishers_aggregation
      {
        size: 0,
        aggs: {
          organisations: {
            nested: {
              path: "organisation"
            },
            aggs: {
              org_titles: {
                terms: {
                  field: "organisation.title.raw",
                  order: {_term: "asc"},
                  size: TERMS_SIZE
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

    def self.datafile_formats_aggregation
      {
        "size": 0,
        "aggs": {
          "datafiles": {
            "nested": {
              "path": "datafiles"
            },
            "aggs": {
              "datafile_formats": {
                "terms": {
                  "field": "datafiles.format"
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
      publisher_param = params['publisher']
      location_param = params['location']
      format_param = params['format']
      query_param = params['q']
      sort_param = params['sort']

      query = {
        query: {
          bool: {}
        }
      }

      case sort_param
        when "recent"
          query[:sort] = {"last_updated_at": {"order": "desc"}}
      end

      unless publisher_param.blank?
        query[:query][:bool][:must] ||= []
        query[:query][:bool][:must] << publisher_filter(publisher_param)
      end

      unless location_param.blank?
        query[:query][:bool][:must] ||= []
        query[:query][:bool][:must] << location_filter(location_param)
      end

      unless format_param.blank?
        query[:query][:bool][:must] ||= []
        query[:query][:bool][:must] << format_filter(format_param)
      end

      unless query_param.blank?
        query[:query][:bool][:must] ||= []
        query[:query][:bool][:must] << multi_match(query_param)
      end

      query
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

    def self.multi_match(query)
      {
        multi_match: {
          query: query,
          fields: %w(title summary description organisation^2 location*^2)
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

    private_class_method :multi_match, :publisher_filter, :location_filter, :format_filter
  end
end
