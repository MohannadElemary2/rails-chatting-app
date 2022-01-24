class ElasticsearchRepository
    include Elasticsearch::Persistence::Repository
end

ELASTIC_SEARCH_REPOSITORY = ElasticsearchRepository.new

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