require 'rails_helper'

RSpec.describe DatasetsHelper do
  describe '#edit_dataset_url' do
    it 'uses the normal view if there are datafiles' do
      dataset = build :dataset, :with_datafile, legacy_name: 'foo'
      url = helper.edit_dataset_url(dataset)
      expect(url).to eq 'https://data.gov.uk/dataset/edit/foo'
    end

    it 'uses the dataset editor even when there are no datafiles' do
      dataset = build :dataset, legacy_name: 'foo'
      url = helper.edit_dataset_url(dataset)
      expect(url).to eq 'https://data.gov.uk/dataset/edit/foo'
    end
  end

  describe '#sort_by_created_at' do
    let(:datafile1) { build :datafile, created_at: 1.hours.ago.iso8601 }
    let(:datafile2) { build :datafile, created_at: 2.hours.ago.iso8601 }

    it 'orders datafiles lexicographically by created_at' do
      results = helper.sort_by_created_at([datafile2, datafile1])
      expect(results).to eq [datafile1, datafile2]
    end
  end

  describe '#contact_email_is_email?' do
    it 'returns true when the email is valid' do
      dataset = build :dataset, contact_email: 'foo@bar.com'
      expect(helper.contact_email_is_email?(dataset)).to be_truthy
    end

    it 'returns false when the email is invalid' do
      dataset = build :dataset, contact_email: 'http://foo.com'
      expect(helper.contact_email_is_email?(dataset)).to be_falsey
    end
  end
end
