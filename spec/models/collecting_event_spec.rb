require 'rails_helper'

describe CollectingEvent, type: :model, group: [:geo, :collecting_events] do
  let(:collecting_event) { CollectingEvent.new }
  let(:county) { FactoryGirl.create(:valid_geographic_area_stack) }
  let(:state) { county.parent }
  let(:country) { state.parent }

  context 'validation' do
    context 'time start/end' do
      specify 'if time_start_minute provided time_start_hour_required' do
        collecting_event.time_start_minute = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_start_hour)).to be_truthy
      end

      specify 'if time_start_second provided time_start_minute_required' do
        collecting_event.time_start_second = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_start_minute)).to be_truthy
      end

      specify 'if time_end_minute provided time_end_hour_required' do
        collecting_event.time_end_minute = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_end_hour)).to be_truthy
      end

      specify 'if time_end_second provided time_end_minute_required' do
        collecting_event.time_end_second = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_end_minute)).to be_truthy
      end
    end

    specify 'if verbatim_geolocation_uncertainty is provided, then so too are verbatim_longitude and verbatim_latitude' do
      collecting_event.verbatim_geolocation_uncertainty = 'based on my astrolab'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_geolocation_uncertainty)).to be_truthy
    end

    specify 'corresponding verbatim_latitude value is provided' do
      collecting_event.verbatim_latitude = '12.345'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_longitude)).to be_truthy
    end

    specify 'corresponding verbatim_longitude value is provided' do
      collecting_event.verbatim_longitude = '12.345'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_latitude)).to be_truthy
    end

    specify 'start_date_year is valid as 4 digit integer' do
      # You can also pass a string, casting is automatic
      collecting_event.start_date_year = 1942
      collecting_event.valid?
      expect(collecting_event.errors[:start_date_year].size).to eq(0)
    end

    specify 'start_date_year is invalid as 3 digit integer' do
      collecting_event.start_date_year = '194'
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
    end

    specify 'start_date_year is invalid as when > 5 years from the future' do
      collecting_event.start_date_year = (Time.now.year + 6)
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
    end

    specify 'start_date_year is invalid when less than 1000' do
      collecting_event.start_date_year = 999
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
    end

    specify 'end_date_year is valid as 4 digit integer' do
      # You can also pass a string, casting is automatic
      collecting_event.end_date_year = 1942
      collecting_event.valid?
      expect(collecting_event.errors[:end_date_year]).to eq([])
    end

    specify 'end_date_year is invalid as 3 digit integer' do
      collecting_event.end_date_year = '194'
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
    end

    specify 'end_date_year is invalid as when > 5 years from the future' do
      collecting_event.end_date_year = Time.now.year + 6
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
    end

    specify 'end_date_year is invalid when less than 1000' do
      collecting_event.end_date_year = 999
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
    end

    specify 'start_date_month is invalid when not included in 1-12' do
      ['ab', 'February', 13, 0].each do |m|
        collecting_event.start_date_month = m
        collecting_event.valid?
        expect(collecting_event.errors.include?(:start_date_month)).to be_truthy
      end
    end

    specify 'start_date_day is invalid when not an integer' do
      collecting_event.start_date_day = "a"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_day)).to be_falsey
    end

    specify 'start_date_day is value bound by month' do
      collecting_event.start_date_year  = "1945" # requires year for leaps
      collecting_event.start_date_month = "2"
      collecting_event.start_date_day   = "30"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_day)).to be_truthy
    end

    specify 'start_date_month is invalid when nil AND start_date_day provided' do
      collecting_event.start_date_day = 1
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_month)).to be_truthy
    end

    specify 'end_date_month is invalid when not included in 1-12' do
      ['ab', 'February', 13, 0].each do |m|
        collecting_event.end_date_month = m
        collecting_event.valid?
        expect(collecting_event.errors.include?(:end_date_month)).to be_truthy
      end
    end

    specify 'end_date_day is invalid when not an integer' do
      collecting_event.end_date_day = "a"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_day)).to be_falsey
    end

    specify 'end_date_day is value bound by month' do
      collecting_event.end_date_year  = "1945" # requires year for leaps
      collecting_event.end_date_month = "2"
      collecting_event.end_date_day   = "30"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_day)).to be_truthy
    end

    specify 'end_date_month is invalid when nil AND end_date_day provided' do
      collecting_event.end_date_day = 1
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_month)).to be_truthy
    end

    specify 'end date is > start date when both are provided' do
      message                           = 'End date is earlier than start date.'
      collecting_event.start_date_day   = 2
      collecting_event.start_date_month = 1
      collecting_event.start_date_year  = 1

      collecting_event.end_date_day   = 1
      collecting_event.end_date_month = 1
      collecting_event.end_date_year  = 1

      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors[:base].include?(message)).to be_truthy
    end

    specify 'end date is > start date when both are provided' do
      message                           = 'End date is earlier than start date.'
      collecting_event.start_date_day   = "26"
      collecting_event.start_date_month = "6"
      collecting_event.start_date_year  = "1970"

      collecting_event.end_date_day = "24"
      collecting_event.end_date_month = "7"
      collecting_event.end_date_year  = "1970"

      expect(collecting_event.valid?).to be_truthy
      expect(collecting_event.errors[:base].include?(message)).to be_falsey
    end

    specify 'end date without start date' do
      message                         = 'End date without start date.'
      collecting_event.end_date_day   = 1
      collecting_event.end_date_month = 1
      collecting_event.end_date_year  = 1789

      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors[:base].include?(message)).to be_truthy
    end

    specify 'maximum elevation is greater than minimum elevation when both provided' do
      message                            = 'Maximum elevation is lower than minimum elevation.'
      collecting_event.minimum_elevation = 2
      collecting_event.maximum_elevation = 1
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors[:maximum_elevation].include?(message)).to be_truthy
    end

    specify 'md5_of_verbatim_collecting_event is unique within project' do
      label = "Label\nAnother line\nYet another line."
      c1    = FactoryGirl.create(:valid_collecting_event, verbatim_label: label)
      c2    = FactoryGirl.build(:valid_collecting_event, verbatim_label: label)
      expect(c2.valid?).to be_falsey
      expect(c2.errors[:md5_of_verbatim_label].count).to eq(1)
    end
  end

  context 'soft validation' do
    specify 'at least some label is provided' do
      message = 'At least one label type, or field notes, should be provided.'
      collecting_event.soft_validate
      expect(collecting_event.soft_validations.messages_on(:base).include?(message)).to be_truthy
    end
  end

  context '#cached' do
    context 'when #no_cached = true' do
      before {
        collecting_event.no_cached = true
        collecting_event.save!
      }
      specify 'nothing is cached' do
        expect(collecting_event.cached.blank?).to be_truthy
      end
    end

    context 'when #no_cached = false, nil' do
      specify 'after save with no data cached is *not* blank?' do
        collecting_event.save!
        expect(collecting_event.cached.blank?).to be_falsey, collecting_event.cached
      end

      context 'contents of cached' do
        context 'with geographic_area set' do
          before{
            collecting_event.save!
            collecting_event.update_attribute(:geographic_area_id, county.id)
          }

          specify 'summarized in first line' do
            expect(collecting_event.cached).to eq('United States of America: Illinois: Champaign')
          end
        end

        specify 'just dates' do
          collecting_event.start_date_day   = 1
          collecting_event.start_date_month = 1
          collecting_event.start_date_year  = 1511

          collecting_event.end_date_day   = 2
          collecting_event.end_date_month = 2
          collecting_event.end_date_year  = 1522

          collecting_event.save!
          expect(collecting_event.cached.blank?).to be_falsey
          expect(collecting_event.cached.strip).to eq('01/01/1511-02/02/1522')
        end

        specify 'just start date' do
          collecting_event.start_date_day   = 1
          collecting_event.start_date_month = 1
          collecting_event.start_date_year  = 1511

          collecting_event.save!
          expect(collecting_event.cached.blank?).to be_falsey
          expect(collecting_event.cached.strip).to eq('01/01/1511')
        end

        specify 'just verbatim_label' do
          collecting_event.verbatim_label = 'Just this thing.'

          collecting_event.save!
          expect(collecting_event.cached.blank?).to be_falsey
          expect(collecting_event.cached.strip).to eq('Just this thing.')
        end

      end
    end
  end

  context 'actions' do
    specify 'if a verbatim_label is present then a md5_of_verbatim_label is generated' do
      collecting_event.verbatim_label = "Label\nAnother line\nYet another line."
      expect(collecting_event.md5_of_verbatim_label.blank?).to be_falsey
    end
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'geographic_area' do
        expect(collecting_event.geographic_area = GeographicArea.new()).to be_truthy
      end
    end
    context 'has_many' do
      specify 'collection_objects' do
        expect(collecting_event.collection_objects << CollectionObject.new).to be_truthy
      end

      specify 'georeferences' do
        expect(collecting_event.georeferences << Georeference.new).to be_truthy
      end

      specify 'geographic_items' do
        expect(collecting_event.geographic_items << GeographicItem.new).to be_truthy
      end
    end
  end

  context 'fuzzy matching' do
    before {
      @c1 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a base string.')
      @c2 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a base string.')

      @c3 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a roof string.')
      @c4 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a r00f string.')
    }

    specify 'nearest_by_levenshtein(compared_string = nil, column = "verbatim_locality", limit = 10)' do
      expect(@c1.nearest_by_levenshtein(@c1.verbatim_locality).first).to eq(@c2)
      expect(@c2.nearest_by_levenshtein(@c2.verbatim_locality).first).to eq(@c1)
      expect(@c3.nearest_by_levenshtein(@c3.verbatim_locality).first).to eq(@c4)
      expect(@c4.nearest_by_levenshtein(@c4.verbatim_locality).first).to eq(@c3)
    end
  end

  specify '#time_start pads' do
    collecting_event.time_start_hour   = 4
    collecting_event.time_start_minute = 2
    collecting_event.time_start_second = 1
    expect(collecting_event.time_start).to eq('04:02:01')
  end

  specify '#time_end pads' do
    collecting_event.time_end_hour   = 4
    collecting_event.time_end_minute = 2
    collecting_event.time_end_second = 1
    expect(collecting_event.time_end).to eq('04:02:01')
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
    it_behaves_like 'documentation'
  end

end
