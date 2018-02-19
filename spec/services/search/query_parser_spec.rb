require 'rails_helper'

RSpec.describe Search::QueryParser do
  subject(:query_parser) { described_class.new }

  describe '.parse' do
    subject { query_parser.parse(query) }

    context 'with a simple query' do
      let(:query) { 'quick brown fox' }

      it 'returns a clause for the terms of the query' do
        expected_query = a_collection_containing_exactly(
          a_hash_including(
            clause: a_hash_including(
              terms: a_collection_containing_exactly(
                a_hash_including(term: 'quick'),
                a_hash_including(term: 'brown'),
                a_hash_including(term: 'fox')
              )
            )
          )
        )

        is_expected.to match(query: expected_query)
      end
    end

    context 'with a quoted query' do
      let(:query) { '"quick brown fox"' }

      it 'returns a clause with a phrase made up of each term in the query' do
        expected_query = a_collection_containing_exactly(
          a_hash_including(
            clause: a_hash_including(
              phrase: a_collection_containing_exactly(
                a_hash_including(term: 'quick'),
                a_hash_including(term: 'brown'),
                a_hash_including(term: 'fox')
              )
            )
          )
        )

        is_expected.to match(query: expected_query)
      end
    end

    context 'with a partially quoted query' do
      let(:query) { 'quick "brown fox"' }

      it 'returns a terms clause and a phrase clause' do
        expected_query = a_collection_containing_exactly(
          a_hash_including(
            clause: a_hash_including(
              terms: a_collection_containing_exactly(
                a_hash_including(term: 'quick')
              )
            )
          ),
          a_hash_including(
            clause: a_hash_including(
              phrase: a_collection_containing_exactly(
                a_hash_including(term: 'brown'),
                a_hash_including(term: 'fox')
              )
            )
          )
        )

        is_expected.to match(query: expected_query)
      end
    end

    context 'with a missing closing quote' do
      let(:query) { 'quick "brown fox' }

      specify { expect { subject }.to raise_error(Parslet::ParseFailed) }
    end

    context 'with a missing opening quote' do
      let(:query) { 'quick brown fox"' }

      specify { expect { subject }.to raise_error(Parslet::ParseFailed) }
    end
  end
end
