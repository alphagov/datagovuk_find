require 'rails_helper'

describe Datafile do
  describe "#start_year" do
    it 'returns the start year from the start date' do
      datafile = Datafile.new(DATA_FILES_WITH_START_AND_ENDDATE[0])
      expect(datafile.start_year).to eql 2001
    end

    describe "#most_recent_date" do
      it 'returns updated_at if end date is blank' do
        datafile = Datafile.new(DATAFILES_WITHOUT_START_AND_ENDDATE[0])
        expect(datafile.most_recent_date).to eql datafile.updated_at
      end

      it 'returns the most recent date out of the end date and the updated_at date' do
        raw_datafile = {
          'start_date' => '2001/1/15',
          'end_date' => '2017/1/15',
          'updated_at' => '2016-08-31T14:40:57.528Z'
        }
        datafile = Datafile.new(raw_datafile)

        expect(datafile.most_recent_date).to eql datafile.end_date
      end
    end

    describe "#html?" do
      it 'returns true if datafile is a webpage' do
        datafile = Datafile.new(HTML_DATAFILE)
        expect(datafile.html?).to be true
      end
    end

    describe "#csv?" do
      it 'returns true if datafile is csv' do
        datafile = Datafile.new(CSV_DATAFILE)
        expect(datafile.csv?).to be true
      end
    end
  end
end
