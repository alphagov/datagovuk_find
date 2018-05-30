require 'rails_helper'

RSpec.describe SearchHelper do
  describe '#datafile_formats_for_select' do
    let(:dataset1) do
      build :dataset, datafiles: [build(:datafile, :raw, format: 'foo'),
                                  build(:datafile, :raw, format: '')]
    end

    let(:dataset2) do
      build :dataset, datafiles: [build(:datafile, :raw, format: 'baz'),
                                  build(:datafile, :raw, format: 'baz')]
    end

    it 'returns a sorted list of unique formats' do
      index(dataset1, dataset2)
      expect(datafile_formats_for_select).to eql %w(BAZ FOO)
    end
  end

  describe '#datafile_topics_for_select' do
    it 'returns a sorted list of unique topics' do
      index(build(:dataset, topic: build(:topic, title: 'foo')),
            build(:dataset, topic: build(:topic, title: 'baz')),
            build(:dataset, topic: build(:topic, title: 'baz')))

      expect(dataset_topics_for_select).to eql %w(baz foo)
    end
  end

  describe '#datafile_publishers_for_select' do
    it 'returns a sorted list of unique publishers' do
      index(build(:dataset, organisation: build(:organisation, :raw, title: 'foo')),
            build(:dataset, organisation: build(:organisation, :raw, title: 'baz')),
            build(:dataset, organisation: build(:organisation, :raw, title: 'baz')))

      expect(dataset_publishers_for_select).to eql %w(baz foo)
    end
  end
end
