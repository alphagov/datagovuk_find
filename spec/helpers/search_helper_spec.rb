require 'rails_helper'

describe SearchHelper do
  describe '#datafile_formats_for_select' do
    it 'returns a sorted list of unique formats' do
      dataset_1 = DatasetBuilder.new
        .with_datafiles([{'format' => 'foo'}])
        .build

      dataset_2 = DatasetBuilder.new
        .with_datafiles([{'format' => 'baz'}, {'format' => 'baz'}])
        .build

      index(dataset_1, dataset_2)
      expect(datafile_formats_for_select).to eql ['', 'BAZ', 'FOO']
    end
  end

  describe '#datafile_topics_for_select' do
    it 'returns a sorted list of unique topics' do
      dataset_1 = DatasetBuilder.new.with_topic({'title' =>'foo'}).build
      dataset_2 = DatasetBuilder.new.with_topic({'title' =>'baz'}).build
      dataset_3 = DatasetBuilder.new.with_topic({'title' =>'baz'}).build

      index(dataset_1, dataset_2, dataset_3)
      expect(dataset_topics_for_select).to eql ['', 'baz', 'foo']
    end
  end

  describe '#datafile_publishers_for_select' do
    it 'returns a sorted list of unique publishers' do
      dataset_1 = DatasetBuilder.new.with_publisher('foo').build
      dataset_2 = DatasetBuilder.new.with_publisher('baz').build
      dataset_3 = DatasetBuilder.new.with_publisher('baz').build

      index(dataset_1, dataset_2, dataset_3)
      expect(dataset_publishers_for_select).to eql ['', 'baz', 'foo']
    end
  end
end
