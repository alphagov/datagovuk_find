require "rails_helper"

RSpec.describe FeatureFlag do
  describe ".enabled?" do
    context "when the feature flag is enabled" do
      it "returns true" do
        allow(Rails.configuration).to receive(:x).and_return(double(version_2_collections_enabled: true))

        expect(FeatureFlag.enabled?(:version_2_collections)).to be true
      end
    end

    context "when the feature flag is disabled" do
      it "returns false" do
        allow(Rails.configuration).to receive(:x).and_return(double(version_2_collections_enabled: false))

        expect(FeatureFlag.enabled?(:version_2_collections)).to be false
      end
    end
  end
end
