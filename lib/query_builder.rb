require 'uri'

module QueryBuilder

  def self.get(name)
    {
      query: {
        constant_score: {
          filter: {
            term: {
              name: name
            }
          }
        }
      }
    }
  end

  def self.related_to(id)
    {
      size: 4,
      query: {
        more_like_this: {
          fields: %w(title summary description organisation^2 location*^2),
          like: {
            _type: "dataset",
            _id: id
          },
          min_term_freq: 1,
          min_doc_freq: 1
        }
      }
    }
  end

  def self.search_query(params)
    publisher_param = params['publisher']
    location_param = params['location']
    query_param = params['q']
    sort_param = params['sortby']

    query = {
      query: {
        bool: {}
      }
    }

    case sort_param
      when "recent"
        query[:sort] = {updated_at: :desc}
    end

    unless publisher_param.blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << self.publisher_filter_query(publisher_param)
    end

    unless location_param.blank?
      query[:query][:bool][:filter] ||= []
      query[:query][:bool][:filter] << {term: {location1: location_param}}
    end

    unless query_param.blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << self.multi_match_query(query_param)
    end

    query
  end

  def self.multi_match_query(query)
    {
      multi_match: {
        query: query,
        fields: %w(title summary description organisation^2 location*^2)
      }
    }
  end

  def self.publisher_filter_query(publisher)
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
end
