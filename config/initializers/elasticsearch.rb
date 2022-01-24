class ElasticsearchRepository
  include Elasticsearch::Persistence::Repository
end

client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: true)

ELASTIC_SEARCH_REPOSITORY = ElasticsearchRepository.new(client: client)

ELASTIC_SEARCH_REPOSITORY.settings({index: {
      analysis: {filter: {autocomplete_filter: {
        type: "ngram",
        min_gram: 3,
        max_gram: 4
      }}, analyzer: {
        ngram_analyzer: {
          tokenizer: "standard",
          filter: ["lowercase", "autocomplete_filter"]
        }
      }}
  }})

ELASTIC_SEARCH_REPOSITORY.mappings { indexes :body, analyzer: 'ngram_analyzer' }

ELASTIC_SEARCH_REPOSITORY.create_index!