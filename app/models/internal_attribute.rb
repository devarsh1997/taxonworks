# The DataAttribute that has a Predicate that is internally defined in TaxonwWorks.
#
# Internal attributes have stronger semantics that ImportAttributes in that the user has had to first
# create a Predicate (which is a controlled vocabulary subclass), which in turn requires a definition. 

# @!attribute controlled_vocabulary_term_id 
#   @return [id]
#   The the id of the ControlledVocabularyTerm::Predicate.  Term is referenced as .predicate.
#
class InternalAttribute < DataAttribute 
  belongs_to :predicate, foreign_key: 'controlled_vocabulary_term_id', inverse_of: :internal_attributes, class_name: 'Predicate'

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :value, scope: [:attribute_subject_id, :attribute_subject_type, :type, :controlled_vocabulary_term_id]


end
