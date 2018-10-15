def delete_index
  Elasticsearch::Model.client.indices.delete index: "datasets-test"
rescue StandardError
  Rails.logger.debug("No test search index to delete")
end

def create_index
  Rails.logger.info("Creating datasets-test index")

  Elasticsearch::Model.client.indices.create(
    index: "datasets-test",
    body: {
      settings: index_settings,
      mappings: index_mappings
    }
  )
rescue StandardError
  Rails.logger.debug("Could not create datasets-test index")
end

def index_settings
  {
    number_of_shards: 1, # necessary so our relevance specs work (more info: https://www.elastic.co/guide/en/elasticsearch/guide/current/relevance-is-broken.html)
    analysis: {
      normalizer: {
        lowercase_normalizer: {
          type: "custom",
          filter: "lowercase"
        }
      }
    }
  }
end

def index_mappings
  {
    dataset: {
      properties: {
        name: {
          type: "keyword",
          index: true,
        },
        title: {
          type: 'text',
          fields: {
            keyword: {
              type: 'keyword',
              index: true,
            },
            english: {
              type: 'text',
              analyzer: 'english',
            },
          },
        },
        summary: {
          type: 'text',
          fields: {
            keyword: {
              type: 'keyword',
              index: true,
            },
            english: {
              type: 'text',
              analyzer: 'english',
            },
          },
        },
        description: {
          type: 'text',
          fields: {
            keyword: {
              type: 'keyword',
              index: true,
            },
            english: {
              type: 'text',
              analyzer: 'english',
            },
          },
        },
        legacy_name: {
          type: "keyword",
          index: true,
        },
        uuid: {
          type: "keyword",
          index: true,
        },
        location1: {
          type: 'text',
          fields: {
            raw: {
              type: "keyword",
              index: true,
            }
          }
        },
        topic: {
          type: 'nested',
          properties: {
            title: {
              type: 'text',
              fields: {
                raw: {
                  type: "keyword",
                  index: true,
                }
              }
            }
          }
        },
        organisation: {
          type: "nested",
          properties: {
            title: {
              type: "text",
              fields: {
                raw: {
                  type: "keyword",
                  index: true,
                },
                english: {
                  type: 'text',
                  analyzer: 'english',
                }
              }
            },
            description: {
              type: 'text',
              fields: {
                raw: {
                  type: 'keyword',
                  index: true,
                },
                english: {
                  type: 'text',
                  analyzer: 'english',
                },
              },
            },
          }
        },
        datafiles: {
          type: "nested",
          properties: {
            format: {
              type: "keyword",
              normalizer: "lowercase_normalizer"
            }
          }
        },
        docs: {
          type: "nested",
          properties: {
            format: { type: "keyword" }
          }
        }
      }
    }
  }
end
