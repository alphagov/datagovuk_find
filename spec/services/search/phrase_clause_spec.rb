require 'rails_helper'

RSpec.describe Search::PhraseClause do
  subject { described_class.new(phrase) }

  let(:phrase) { double }

  it { is_expected.to have_attributes(phrase: phrase) }
end
