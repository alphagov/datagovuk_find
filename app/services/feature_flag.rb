class FeatureFlag
  def self.enabled?(flag_name)
    Rails.configuration.x.version_2_collections_enabled if flag_name == :version_2_collections
  end
end
