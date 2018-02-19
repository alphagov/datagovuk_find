require 'rails_helper'

RSpec.describe Search::TermsClause do
  subject { described_class.new(terms) }

  let(:terms) { double }

  it { is_expected.to have_attributes(terms: terms) }
end
