require 'rails_helper'

RSpec.describe SearchHelper do
  describe '#datafile_formats_for_select' do
    it 'returns a sorted list of unique formats' do
      dataset1 = DatasetBuilder.new
                  .with_datafiles([{ 'format' => 'foo' }, { 'format' => '' }])
                  .build

      dataset2 = DatasetBuilder.new
                  .with_datafiles([{ 'format' => 'baz' }, { 'format' => 'baz' }])
                  .build

      index(dataset1, dataset2)
      expect(datafile_formats_for_select).to eql %w(BAZ FOO)
    end
  end

  describe '#datafile_topics_for_select' do
    it 'returns a sorted list of unique topics' do
      dataset1 = DatasetBuilder.new.with_topic('title' => 'foo').build
      dataset2 = DatasetBuilder.new.with_topic('title' => 'baz').build
      dataset3 = DatasetBuilder.new.with_topic('title' => 'baz').build

      index(dataset1, dataset2, dataset3)
      expect(dataset_topics_for_select).to eql %w(baz foo)
    end
  end

  describe '#datafile_publishers_for_select' do
    it 'returns a sorted list of unique publishers' do
      dataset1 = DatasetBuilder.new.with_publisher('foo').build
      dataset2 = DatasetBuilder.new.with_publisher('baz').build
      dataset3 = DatasetBuilder.new.with_publisher('baz').build

      index(dataset1, dataset2, dataset3)
      expect(dataset_publishers_for_select).to eql %w(baz foo)
    end
  end
end
