class Organisation
  include ActiveModel::Model

  attr_accessor :id, :name, :title, :description, :abbreviation,
                :replace_by, :contact_email, :contact_phone, :contact_name,
                :foi_email, :foi_phone, :foi_name, :foi_web, :category,
                :organisation_user_id, :created_at, :updated_at, :uuid,
                :active, :org_type, :ancestry, :govuk_content_id
end
