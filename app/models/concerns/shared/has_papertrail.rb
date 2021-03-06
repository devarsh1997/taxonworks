# Shared code for models using PaperTrail
#
module Shared::HasPapertrail

  extend ActiveSupport::Concern 
  included do
    has_paper_trail on: [:update]

    before_save(on: :update) do
      PaperTrail.whodunnit = $user_id
    end
  end

end
