class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished < TaxonNameClassification::Icn::EffectivelyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished)
  end

  def self.gbif_status
    'invalidum'
  end

end