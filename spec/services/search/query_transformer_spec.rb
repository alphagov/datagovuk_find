require 'rails_helper'

RSpec.describe Search::QueryTransformer do
  subject(:query_transformer) { described_class.new }

  describe '.apply' do
    subject { query_transformer.apply(parse_tree) }

    let(:parse_tree) { Search::QueryParser.new.parse(query) }
    let(:query) { 'quick brown fox' }

    it 'builds a search query' do
      is_expected.to be_a(Search::Query)
    end

    context 'with a simple query' do
      let(:query) { 'quick brown fox' }

      it 'transforms the query into a collection of term clauses' do
        is_expected
          .to have_attributes(
            clauses: a_collection_containing_exactly(
              an_instance_of(Search::TermsClause)
                .and(have_attributes(terms: 'quick brown fox'))
            )
          )
      end
    end

    context 'with a quoted query' do
      let(:query) { '"quick brown fox"' }

      it 'transforms the query into a phrase clauses' do
        is_expected
          .to have_attributes(
            clauses: a_collection_containing_exactly(
              an_instance_of(Search::PhraseClause)
                .and(have_attributes(phrase: 'quick brown fox'))
            )
          )
      end
    end

    context 'with a partially quoted query' do
      let(:query) { 'quick "brown fox"' }

      it 'transforms the query into term and phrase clauses' do
        is_expected
          .to have_attributes(
            clauses: a_collection_containing_exactly(
              an_instance_of(Search::TermsClause)
                .and(have_attributes(terms: 'quick')),
              an_instance_of(Search::PhraseClause)
                .and(have_attributes(phrase: 'brown fox'))
            )
          )
      end
    end
  end
end
