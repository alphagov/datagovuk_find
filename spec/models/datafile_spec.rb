require 'rails_helper'

RSpec.describe Datafile do
  describe "#start_year" do
    it 'returns the start year from the start date' do
      datafile = build :datafile, start_date: '2001/1/15'
      expect(datafile.start_year).to eql 2001
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
