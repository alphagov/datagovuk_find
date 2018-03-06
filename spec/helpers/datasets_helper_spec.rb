require 'rails_helper'

RSpec.describe DatasetsHelper do
  describe '#edit_dataset_url' do
    subject { helper.edit_dataset_url(dataset) }

    before { index attributes }

    let(:dataset) { Dataset.get_by_uuid(uuid: attributes[:uuid]) }
    let(:legacy_name) { 'abc123' }

    context 'when released' do
      let(:attributes) do
        DatasetBuilder
          .new
          .with_legacy_name(legacy_name)
          .with_datafiles([Datafile.new(CSV_DATAFILE)])
          .build
      end

      it { is_expected.to eq('https://data.gov.uk/dataset/edit/abc123') }
    end

    context 'when not released' do
      let(:attributes) do
        DatasetBuilder
          .new
          .with_legacy_name(legacy_name)
          .build
      end

      it { is_expected.to eq('https://data.gov.uk/unpublished/edit-item/abc123') }
    end
  end
end
