FactoryGirl.define do
  factory :taxon_determination, traits: [:housekeeping] do
    factory :valid_taxon_determination do
       association :otu, factory: :valid_otu
       association :biological_collection_object, factory: :valid_specimen
       # !! association :determiner, factory: :valid_determiner needs to be built
     end 
  end
end
