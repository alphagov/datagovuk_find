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

  describe '#contact_email_is_email?' do
    it 'returns true when the email is valid' do
      dataset = Dataset.new(DatasetBuilder.new.with_contact_email('foo@bar.com').build)
      expect(helper.contact_email_is_email?(dataset)).to be_truthy
    end

    it 'returns false when the email is invalid' do
      dataset = Dataset.new(DatasetBuilder.new.with_contact_email('http://foo.com').build)
      expect(helper.contact_email_is_email?(dataset)).to be_falsey
    end
  end
end
