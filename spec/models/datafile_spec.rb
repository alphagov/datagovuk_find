require 'rails_helper'

RSpec.describe Datafile do
  describe "#start_year" do
    it 'returns the start year from the start date' do
      datafile = build :datafile, start_date: '2001/1/15'
      expect(datafile.start_year).to eql 2001
    end

    describe "#most_recent_date" do
      it 'returns updated_at if end date is blank' do
        datafile = build :datafile
        expect(datafile.most_recent_date).to eq datafile.updated_at
      end

      it 'returns the most recent date out of the end date and the updated_at date' do
        datafile = build :datafile, start_date: '2001/1/15',
                                    end_date: '2017/1/15',
                                    updated_at: '2016-08-31T14:40:57.528Z'

        expect(datafile.most_recent_date).to eq datafile.end_date
      end
    end

    describe "#html?" do
      it 'returns true if datafile is a webpage' do
        datafile = build :datafile, format: 'html'
        expect(datafile.html?).to be true
      end
    end

    describe "#csv?" do
      it 'returns true if datafile is csv' do
        datafile = build :datafile
        expect(datafile.csv?).to be true
      end
    end
  end
end
