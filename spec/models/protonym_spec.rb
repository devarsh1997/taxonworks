require 'spec_helper'

describe Protonym do

  let(:protonym) { Protonym.new }

  context 'associations' do
    context 'has_many' do
      specify 'original_description_relationships' do 
        expect(protonym).to respond_to(:original_description_relationships)
      end
    end

    context 'has_one' do
      specify 'original_description_source' do
        expect(protonym).to respond_to(:original_description_source)
      end

      context 'type_taxon_name_relationship' do

        context 'typification' do
          before do
            # make the protonym a type of a genus
            protonym.name = 'aus'
            protonym.rank_class = Ranks.lookup(:iczn, 'species')
            protonym.save
            @genus = FactoryGirl.create(:iczn_genus)
            @family = @genus.ancestor_at_rank('family')
            @species_type_of_genus = FactoryGirl.create(:taxon_name_relationship,
                                                        subject: protonym,
                                                        object: @genus, 
                                                        type: TaxonNameRelationship::Typification::Genus::Monotypy::Original)

            @genus_type_of_family = FactoryGirl.create(:taxon_name_relationship,
                                                       subject: @genus,
                                                       object: @family, 
                                                       type: TaxonNameRelationship::Typification::Family)
          end

          specify 'type_taxon_name' do
            expect(@genus).to respond_to(:type_taxon_name)
            expect(@genus.type_taxon_name).to eq(protonym)
            expect(@family.type_taxon_name).to eq(@genus)
          end 

          specify 'type_taxon_name_relationship' do
            expect(protonym).to respond_to(:type_taxon_name_relationship)
            expect(@genus.type_taxon_name_relationship.id).to eq(@species_type_of_genus.id)
            expect(@family.type_taxon_name_relationship.id).to eq(@genus_type_of_family.id)
          end 

          specify 'has at most one has_type relationship' do
            extra_type_relation = FactoryGirl.build(:taxon_name_relationship,
                                                       subject: @genus,
                                                       object: @family, 
                                                       type: TaxonNameRelationship::Typification::Family)
            # Handled by TaxonNameRelationship validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]
            expect(extra_type_relation.valid?).to be_false
          end

          # A taxon_name can be a type of multiple other names
          specify 'type_of_relationships' do
              expect(protonym.type_of_relationships.collect{|i| i.id}).to eq([@species_type_of_genus.id])
          end
          specify 'type_of_taxon_names' do
              expect(protonym.type_of_taxon_names).to eq([@genus])
          end
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_description_#{rank}_relationship" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end
      end

      context 'taxon_names' do
        %w{genus subgenus species}.each do |rank|
          method = "original_#{rank}" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end
      end
    end
  end
end
