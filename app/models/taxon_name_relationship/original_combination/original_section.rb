class TaxonNameRelationship::OriginalCombination::OriginalSection < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::OriginalCombination::OriginalGenus)
  end

  def self.assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :section_in_original_combination
  end

  # as. 
  def self.inverse_assignment_method
    # aus.original_section = bus
    :original_section
  end

  def self.assignable
    true
  end

end
