require 'uri'

module QueryBuilder

  def get_query(name: '', id: '')
    key_value_pair =
      name.empty? ? {_id: id} : {name: name}
    {
      query: {
        constant_score: {
          filter: {
            term: key_value_pair
          }
        }
      }
    }
  end

  def publishers_aggregation_query
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
                size: 10000
              }
            }
          }
        }
      }
    }
  end

  def locations_aggregation_query
    {
      size: 0,
      aggs: {
        locations: {
          terms: {
            field: 'location1.raw',
            order: {_term: 'asc'}
          }
        }
      }
    }
  end

  def related_to_query(id)
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

  def search_query(params)
    publisher_param = params['publisher']
    location_param = params['location']
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
      query[:query][:bool][:must] << publisher_filter_query(publisher_param)
    end

    unless location_param.blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << location_filter_query(location_param)
    end

    unless query_param.blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << multi_match_query(query_param)
    end

    query
  end

  private

  def multi_match_query(query)
    {
      multi_match: {
        query: query,
        fields: %w(title summary description organisation^2 location*^2)
      }
    }
  end

  def publisher_filter_query(publisher)
    {
      nested: {
        path: "organisation",
        query: {
          bool: {
            must: [
              {
                match: {
                  "organisation.title": publisher
                }
              }
            ]
          }
        }
      }
    }
  end

  def location_filter_query(location)
    {
      match: {
        location1: location
      }
    }
  end
end
