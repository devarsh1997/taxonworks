# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :taxon_name_relationship_iczn, :class => 'TaxonNameRelationship::Iczn', traits: [:housekeeping] do
  end
end
