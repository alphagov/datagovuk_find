require 'rails_helper'

RSpec.describe Dataset do
  describe "#schema_id" do
    it 'recognises legacy schema_id as an organogram' do
      dataset = build :dataset, schema_id: '["d3c0b23f-6979-45e4-88ed-d2ab59b005d0"]'
      expect(dataset.organogram?).to be true
    end

    it 'recognises new schema_id as an organogram' do
      dataset = build :dataset, schema_id: 'd3c0b23f-6979-45e4-88ed-d2ab59b005d0'
      expect(dataset.organogram?).to be true
    end

    it 'does not recognise other ids as an organogram' do
      dataset = build :dataset, schema_id: 'non-organogram'
      expect(dataset.organogram?).to be false
    end
  end
end
