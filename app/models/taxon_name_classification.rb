class TaxonNameClassification < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include SoftValidation

  belongs_to :taxon_name

  before_validation :validate_taxon_name_classlassification
  validates_presence_of :taxon_name, presence: true
  validates_presence_of :type, presence: true
  validates_uniqueness_of :taxon_name_id, scope: :type

  # TODO: validate_corresponding_nomenclatural_code (ICZN should match with rank etc.)

  scope :where_taxon_name, -> (taxon_name) {where(taxon_name_id: taxon_name)}
  scope :with_type_string, -> (base_string) {where('type LIKE ?', "#{base_string}" ) }
  scope :with_type_base, -> (base_string) {where('type LIKE ?', "#{base_string}%" ) }
  scope :with_type_array, -> (base_array) {where('type IN (?)', base_array ) }
  scope :with_type_contains, -> (base_string) {where('type LIKE ?', "%#{base_string}%" ) }
  scope :not_self, -> (id) {where('id != ?', id )}

  soft_validate(:sv_proper_classification, set: :proper_classification)
  soft_validate(:sv_validate_disjoint_classes, set: :validate_disjoint_classes)
  soft_validate(:sv_not_specific_classes, set: :not_specific_classes)

  # years of applicability for each class
  def self.code_applicability_start_year
    1
  end

  def self.code_applicability_end_year
    9999
  end

  def self.applicable_ranks
    []
  end

  def self.disjoint_taxon_name_classes
    []
  end

  # Return a String with the "common" name for this class.
  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def self.possible_species_endings
    nil
  end

  def self.questionable_species_endings
    nil
  end

  def self.possible_genus_endings
    nil
  end

  def type_name
    r = self.type.to_s
    TAXON_NAME_CLASS_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = TAXON_NAME_CLASS_NAMES.include?(r) ? r.safe_constantize : nil
    r
  end

  def validate_taxon_name_classlassification
    errors.add(:type, "Status not found") if !self.type.nil? and !TAXON_NAME_CLASS_NAMES.include?(self.type.to_s)
  end

  #TODO: validate, that all the taxon_classes in the table could be linked to taxon_classes in classes (if those had changed)

  #region Soft validation

  def sv_proper_classification
    # type is a string already 
    if TAXON_NAME_CLASS_NAMES.include?(self.type)
      # self.type_class is a Class
      if not self.type_class.applicable_ranks.include?(self.taxon_name.rank_class.to_s)
        soft_validations.add(:type, 'The status is unapplicable to the name of ' + self.taxon_name.rank_class.rank_name + ' rank')
      end
    end
    y = self.taxon_name.year_of_publication
    if not y.nil?
      if y > self.type_class.code_applicability_end_year || y < self.type_class.code_applicability_start_year
        soft_validations.add(:type, 'The status is unapplicable to the name published in ' + y.to_s)
      end
    end
  end

  def sv_validate_disjoint_classes
    classifications = TaxonNameClassification.where_taxon_name(self.taxon_name).not_self(self)
    classifications.each  do |i|
      soft_validations.add(:type, "Conflicting with another status: '#{i.type_name}'") if self.type_class.disjoint_taxon_name_classes.include?(i.type_name)
    end
  end

  def sv_not_specific_classes
    case self.type_name
      when 'TaxonNameClassification::Iczn::Available'
        soft_validations.add(:type, 'Please specify if the name is valid or invalid')
      when 'TaxonNameClassification::Iczn::Unavailable'
        soft_validations.add(:type, 'Please specify the reasons for the name being unavailable')
      when 'TaxonNameClassification::Iczn::Available::Invalid'
        soft_validations.add(:type, 'Please replace with appropriate relationship')
      when 'TaxonNameClassification::Iczn::Available::Invalid::Homonym'
        soft_validations.add(:type, 'Please replace with appropriate relationship')
      when 'TaxonNameClassification::Iczn::Available::Valid'
        soft_validations.add(:type, 'Please replace with appropriate relationship')
      when 'TaxonNameClassification::Iczn::Unavailable::Suppressed'
        soft_validations.add(:type, 'Please specify the reasons for the name being suppressed')
      when 'TaxonNameClassification::Iczn::Unavailable::Excluded'
        soft_validations.add(:type, 'Please specify the reasons for the name being excluded')
      when 'TaxonNameClassification::Iczn::Unavailable::NomenNudum'
        soft_validations.add(:type, 'Please specify the reasons for the name being nomen nudum')
      when 'TaxonNameClassification::Iczn::Unavailable::NonBinomial'
        soft_validations.add(:type, 'Please specify the reasons for the name being non binomial')
      when 'TaxonNameClassification::Icn::EffectivelyPublished'
        soft_validations.add(:type, 'Please specify if the name is validly or invalidly published')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished'
        soft_validations.add(:type, 'Please specify the reasons for the name being invalidly published')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished'

        soft_validations.add(:type, 'Please specify if the name is legitimate or illegitimate')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate'
        soft_validations.add(:type, 'Please specify the reasons for the name being Legitimate')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate'
        soft_validations.add(:type, 'Please specify the reasons for the name being Illegitimate')
    end
  end


  #endregion
  
  private
  def self.collect_to_s(*args)
    args.collect{|arg| arg.to_s}
  end
  def self.collect_descendants_to_s(*classes)
    ans = []
    classes.each do |klass|
      ans += klass.descendants.collect{|k| k.to_s}
    end
    ans    
  end
  def self.collect_descendants_and_itself_to_s(*classes)
    classes.collect{|k| k.to_s} + self.collect_descendants_to_s(*classes)
  end
end
