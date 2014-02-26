# A biological property like "male", "adult", "host", "parasite". 
class BiologicalProperty < ControlledVocabularyTerm 
  has_many :biological_relationship_types
end
