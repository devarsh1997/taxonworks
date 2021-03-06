FactoryGirl.define do
  factory :project, class: Project, traits: [:creator_and_updater] do
    # Don't include a name here 
    factory :valid_project do
      name { Faker::Lorem.words(4) }
    end
  end
end
