require 'rails_helper'

describe SearchHelper do
  describe '#datafile_formats_for_select' do
    it 'returns a list of unique datafile formats ordered by datafile count (elasticsearch default)' do
      # More info: https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-nested-aggregation.html

      first_dataset = DatasetBuilder.new
      .with_title('First Dataset Title')
      .with_datafiles([{'format' => 'foo'}])
      .build

      second_dataset = DatasetBuilder.new
      .with_title('Second Dataset Title')
      .with_datafiles([
                      {'format' => 'bar'},
                      {'format' => 'baz'},
                      {'format' => 'baz'}
      ])
      .build

      index([first_dataset, second_dataset])

      expect(datafile_formats_for_select).to eql ['', 'baz', 'bar', 'foo']
    end
  end
end
