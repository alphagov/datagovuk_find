require 'rails_helper'

RSpec.describe DatasetsHelper do
  describe '#edit_dataset_url' do
    let(:attributes) do
      DatasetBuilder.new.with_datafiles(['datafile'])
        .with_legacy_name('foo')
    end

    it 'uses the normal view if there are datafiles' do
      url = helper.edit_dataset_url(Dataset.new(attributes.build))
      expect(url).to eq 'https://data.gov.uk/dataset/edit/foo'
    end

    it 'uses the unpublished view if there are datafiles' do
      unpublished_attributes = attributes.with_datafiles([])
      url = helper.edit_dataset_url(Dataset.new(unpublished_attributes.build))
      expect(url).to eq 'https://data.gov.uk/unpublished/edit-item/foo'
    end
  end

  describe '#sort_by_created_at' do
    it 'orders datafiles lexicographically by created_at' do
      datafile_1 = Datafile.new(created_at: 1.hours.ago.iso8601)
      datafile_2 = Datafile.new(created_at: 2.hours.ago.iso8601)
      results = helper.sort_by_created_at([datafile_2, datafile_1])
      expect(results).to eq [datafile_1, datafile_2]
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
