# A qualitative state, as traditionally used in Phylogenetic characters and descriptive taxonomy.
#
#  @!attribute name 
#   @return [String]
#      the full name of the character state, like "blue" 
#
#  @!attribute label
#   @return [String]
#      the label presented in the matrix, like "0", or "1" 
#
class CharacterState < ApplicationRecord

  include Housekeeping
  include Shared::Depictions
  include Shared::IsData
  include Shared::Notable
  include Shared::Identifiable
  include Shared::Taggable
  include Shared::Confidence
  include Shared::Documentation
  include Shared::Citable
  include Shared::DataAttributes
  include Shared::AlternateValues
  include SoftValidation

  acts_as_list scope: [:descriptor_id]

  ALTERNATE_VALUES_FOR = [:name, :label]

  belongs_to :descriptor

  validates :descriptor, presence: true
  validates_presence_of :name
  validates_presence_of :label
  validates_uniqueness_of :name, scope: [:descriptor_id]
  validates_uniqueness_of :label, scope: [:descriptor_id]

  validate :descriptor_kind

  protected

  def descriptor_kind
    errors.add(:descriptor, 'must be Descriptor::Qualitative') if descriptor && descriptor.type != 'Descriptor::Qualitative'
  end

end
