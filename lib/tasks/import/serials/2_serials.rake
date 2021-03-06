namespace :tw do
  namespace :import do
    namespace :serial do

      desc 'call like "rake tw:import:serial:serials_4_build_SF_serials data_directory=/Users/eef/src/data/serialdata/working_data/SFSerialExport.txt user_id=1" '
      task :serials_4_build_SF_serials => [:environment, :data_directory, :user_id] do |t|
        file = @args[:data_directory] +  'SF_serial_Final.txt' # was SerialExport.txt' 
        # must be run after MX/treehopper serial import

        # First file SF_serial_export.txt
        $stdout.sync = true
        print ('Starting transaction ...')
        error_msg = [] # array for error messages

        begin
          ApplicationRecord.transaction do
            set_serial_import_predicates

            CSV.foreach(file,
                        headers:        true,
                        return_headers: false,
                        encoding:       'UTF-16LE:UTF-8',
                        col_sep:        "\t",
                        quote_char:     '|'
            ) do |row|

              ns = nil # initialize to no found serials
              # TODO convert row to a hash & reference by column name not order to make it more generic
=begin
Column : SQL column name :  data desc
0 : ImportID : file specific import ID
1 : FullName  : Full name of Serial
2 : ShortName  : SF abbreviation
3 : Publisher : Name of the publisher
4 : PlacePublished : Location of the publisher
5 : StartYear : First year serial was published
6 : EndYear : Last year serial was published
7 : Note : general notes
8 : ISSN : ISSN for the serial
9 : MX_T_ImportID : identifier from the MX serial import for when it's unclear which is the correct duplicate name
10 : Make_New : either 'T' or 'F' - indicates that a new serial should be created even if it matches an existing one.

Note on ISSNs - an ISSN can be used once and only once for a serial => if it's already been used for an MXserial,
need to confirm that the 2 serials are the same and add the SF data as AlternateValue::AlternateSpelling
=end
              importID = row[0].to_s.strip
              print ("\r  tmpID #{importID} ")
              fname        = row[1].to_s.strip
              sname        = row[2].to_s.strip
              pub          = row[3].to_s.strip
              place        = row[4].to_s.strip
              syear        = row[5].to_s.strip
              eyear        = row[6].to_s.strip
              note         = row[7].to_s.strip
              issn         = row[8].to_s.strip
              mx_import_id = row[9].to_s.strip
              if row[10].to_s.strip.blank?
                make_new = false
              else
                if row[10].to_s.strip == 'T'
                  make_new = true
                else
                  raise 'unhandled value in Make_New'
                end
              end

              unless make_new
                if mx_import_id.blank?
                  ns = Serial.with_identifier(issn).first
                  if ns.nil? # ISSN is not in use, check for duplicate name
                    sa = Serial.where(name: fname).to_a # does it match a primary name?
                    case sa.count
                      when 0 # not a match to primary name - is it a match to an alt name?
                        ava = AlternateValue.where(value:                            fname,
                                                   alternate_value_object_type:      'Serial',
                                                   alternate_value_object_attribute: 'name')
                        case ava.count
                          when 0
                            ns = nil #go to new serial
                          when 1 # found it - set ns
                            ns = ava.first.alternate_value_object.becomes(Serial)
                          else # don't no what to do?
                            #raise ('matched more than one serial ' + importID)
                            msg = ['matched more than one serial\'s alternate value - ImportID', importID,
                                   " fname:[ #{fname} ]", 'number matched', ava.count,
                                   "adding a new serial \n"].join(' : ')
                            unless ava[0].alternate_value_object.data_attributes.where(import_predicate:
                                                                                         @mx_t_serial_importID_name).any?
                              tmp1 =
                                "attributes: #{ava[0].alternate_value_object.data_attributes.to_s}"
                            else
                              tmp1 =
                                "MX_T_importID #{ava[0].alternate_value_object.data_attributes.where(
                                  import_predicate: @mx_t_serial_importID_name).first.value}"
                            end
                            if ava[1].alternate_value_object.data_attributes.where(import_predicate:
                                                                                     @mx_t_serial_importID_name).first.nil?
                              tmp2 = "attributes: #{ava[1].alternate_value_object.data_attributes.to_s}"
                            else
                              tmp2 =
                                "\n MX_T_importID #{ava[1].alternate_value_object.data_attributes.where(
                                  import_predicate: @mx_t_serial_importID_name).first.value}"
                            end

                            msg = [msg, tmp1, tmp2].join(' : ')
                            error_msg << msg
                            ns = nil # go to new serial
                        end
                      when 1
                        ns = sa.first
                      else
                        # raise ('matched more than one serial ' + importID)
                        msg = ['matched more than one serial ImportID', importID, fname, ' number matched',
                               sa.count, "\n", 'sa[0].import_predicate 1',
                               sa[0].data_attributes[0].import_predicate, 'sa[0].value', sa[0].data_attributes[0].value,
                               'sa[0].import_predicate 2', sa[0].data_attributes[1].import_predicate, 'sa[0].value',
                               sa[0].data_attributes[1].value, "\n", 'sa[1].import_predicate 2',
                               sa[1].data_attributes[0].import_predicate, 'sa[1].value', sa[1].data_attributes[0].value,
                               'sa[1].import_predicate 2', sa[1].data_attributes[1].import_predicate, 'sa[1].value',
                               sa[1].data_attributes[1].value,
                        ].join(' : ')
                        error_msg << msg
                        next
                    end
                  end
                else # have the MX_T_serial import ID
                  nsa = Serial.joins(:data_attributes).where(data_attributes: {value:            mx_import_id,
                                                                               import_predicate: @mx_t_serial_importID_name})
                  case nsa.count # how many serials were found for this value?
                    when 0
                      puts ["\nskipping - unable to find MX serial ", fname, 'importID', importID, 'MX_T_ImportID',
                            mx_import_id].join(" : ")
                      next
                    when 1 # found 1 and only 1 serial - we're good!
                      ns = nsa.first
                    else
                      puts ["\nskipping - match > 1 MX serials ", fname, 'importID', importID, 'MX_T_ImportID',
                            mx_import_id].join(" : ")
                      next
                  end
                end
              end

              # if ns contains an existing serial update it, else create a new serial
              if ns.nil? # make a new serial
                ns = Serial.new(
                  name:                fname,
                  publisher:           pub,
                  place_published:     place,
                  first_year_of_issue: syear,
                  last_year_of_issue:  eyear,
                )
                if ns.valid?
                  ns.save!
                  # add note
                  unless (note.blank?) # test for empty note!
                    ns.data_attributes << ImportAttribute.new(import_predicate: @note_name,
                                                              value:            note)
                  end

                  # Import ID - never empty
                  ns.data_attributes << ImportAttribute.new(import_predicate: @sf_serial_importID_name,
                                                            value:            importID)

                  unless issn.blank? # tested for existing ISSN at top
                    ns.identifiers << Identifier.new(type: 'Identifier::Global::Issn', identifier: issn)
                  end
                else
                  puts "\nerror on primary save tmpID #{importID} -- #{ns.errors.messages} skipping"
                end

              else # ns already contains the relevant serial
                ns.data_attributes << ImportAttribute.new(import_predicate: @sf_serial_importID_name,
                                                          value:            importID)
                unless (note.blank?) # test for empty note!
                  unless ns.data_attributes.where(value: note, import_predicate: @note_name).any?
                    ns.data_attributes << ImportAttribute.new(import_predicate: @note_name,
                                                              value:            note)
                  end
                end
                # is the name already attached to the serial
                unless ns.all_values_for(:name).include?(fname)
                  #ns.alternate_values.where(alternate_value_object_attribute: 'name').map(&:value).include?(fname)
                  begin
                    # printf('name does not match importID[%d] [%s] [%s] [%s]', importID, syear, s.name,
                    #        s.all_values_for(:name))

                    ns.alternate_values << AlternateValue.new(
                      value:                            fname,
                      alternate_value_object_attribute: 'name',
                      type:                             'AlternateValue::AlternateSpelling'
                    )
                    # else
                    #found a match -> do nothing
                    # puts "primary name matched primary name #{s.name}" if s.name == syear
                    # puts 'primary name matched alternate name' if s.all_values_for(:name).include?(syear)
                  end
                end
                # altname check is below
                unless pub.blank? #add publisher
                  if ns.publisher.blank?
                    ns.publisher = pub
                  else
                    unless ns.all_values_for(:publisher).include?(pub)
                      ns.alternate_values << AlternateValue.new(
                        value:                            pub,
                        alternate_value_object_attribute: 'publisher',
                        type:                             'AlternateValue::AlternateSpelling'
                      )
                    end
                  end
                end
                unless place.blank? #add placePublished
                  if ns.place_published.blank?
                    ns.place_published = place
                  else
                    unless ns.all_values_for(:place_published).include?(place)
                      ns.alternate_values << AlternateValue.new(
                        value:                            place,
                        alternate_value_object_attribute: 'place_published',
                        type:                             'AlternateValue::AlternateSpelling'
                      )
                    end
                  end
                end
                unless syear.blank? || syear == '0' # add start year
                  if ns.first_year_of_issue.blank?
                    ns.first_year_of_issue = syear
                  else
                    if ns.first_year_of_issue != syear # add a note
                      ns.data_attributes <<
                        ImportAttribute.new(import_predicate: @note_name,
                                            value:            "conflicting start year on import #{syear}")
                    end
                  end
                end
                unless eyear.blank? || eyear == '0' # add start year
                  if ns.last_year_of_issue.blank?
                    ns.last_year_of_issue = eyear
                  else
                    if ns.last_year_of_issue != eyear # add a note
                      ns.data_attributes <<
                        ImportAttribute.new(import_predicate: @note_name,
                                            value:            "conflicting end year on import #{eyear}")
                    end
                  end
                end
              end # if ns.nil?

              # ns now contains the existing or new serial, so add altname
              if fname != sname # (SF requires both a short & long name so they may be the same)

                unless ns.all_values_for(:name).include?(sname)
                  # printf('name does not match importID[%d] [%s] [%s] [%s]', importID, syear, s.name,
                  #        s.all_values_for(:name))

                  ns.alternate_values << AlternateValue.new(
                    value:                            sname,
                    alternate_value_object_attribute: 'name',
                    type:                             'AlternateValue::Abbreviation'
                  )
                end
              end

              if ns.valid?
                if !ns.place_published.blank?
                  if ns.place_published.length >= 256
                    puts "\nerror on primary save tmpID #{importID} place_published too long -- skipping"
                    #error_msg <<  "place_published too long tmpID #{importID}"
                  else
                    ns.save!
                    # a=1 # here to allow for break point
                  end
                end
              else
                puts "\nerror on primary save tmpID #{importID} -- #{ns.errors.messages} skipping"
                ns.data_attributes.to_a.each do |dattr|
                  puts "#{dattr.value}, #{dattr.type}, #{dattr.import_predicate}, #{dattr.controlled_vocabulary_term_id}"
                end
                puts
                error_msg << ns.errors.messages
              end

            end # transaction end
            puts "\n#{ap(error_msg.flatten.uniq)}\n"
            puts 'Successful load of primary serial file'
            #raise 'preventing load of transaction' # causes it to always fail and rollback the transaction
          end
        rescue
          raise
        end

      end # task


      desc 'call like "rake tw:import:serial:serials_5_add_SF_IDs data_directory=/Users/eef/src/data/serialdata/working_data/ user_id=1" '
      task :serials_5_add_SF_IDs, [:data_directory] => [:environment, :user_id] do |t|

        file = @args[:data_directory] + 'SF_IDmap.txt'  # was 'SFImportIDmap.txt'

        raise 'There are no existing serials, doing nothing.' if Serial.all.count == 0

        # processing second file ./SFImportIDmap.txt - adding SF identifiers
        $stdout.sync = true
        print ('Starting transaction ...')
        error_msg = [] # array for error messages
        warn_msg  = [] # array for warnings

        begin
          ApplicationRecord.transaction do
            set_serial_import_predicates

            CSV.foreach(file,
                        headers:        true,
                        return_headers: false,
                        encoding:       'UTF-16LE:UTF-8',
                        col_sep:        "\t",
                        quote_char:     '|'
            ) do |row|

=begin
SFImportIDMap.txt
  Column : SQL column name :  data desc
  0 : ImportID : file specific import ID
  1 : SFID  : SF publication ID
  2 : SFregID  : SF publication registry ID
=end
              importID = row[0].to_s.strip
              print ("\r  tmpID #{importID} ")
              sfID    = row[1].to_s.strip
              sfregID = row[2].to_s.strip

              # find the correct serial
              s       = nil
              sr      = Serial.joins(:data_attributes).where(data_attributes: {value:            importID,
                                                                               import_predicate: @sf_serial_importID_name})
              # no longer a namespace identifier, now a data attribute
              case sr.count # how many serials were found for this value?
                when 0
                  msg = "skipping - unable to find base serial #{@sf_serial_importID_name} importID #{importID}"
                  error_msg << msg
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s = sr.first
                # print ("\r SerialID #{s.id} : tmpID #{importID} : SFID #{sfID} : SFregID #{sfregID} ")
                else
                  msg = "skipping - found multiple base serial #{@sf_serial_importID_name} importID #{importID}"
                  error_msg << msg
                  next
              end

              unless sfID.blank?
                begin
                  i = s.data_attributes.where(import_predicate: @sf_pubID_name, value: sfID)
                  # i = DataAttribute.where(import_predicate:     @sf_pub_id.name, attribute_subject_type: 'Serial',
                  #                         attribute_subject_id: s.id, value: sfID)
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << ImportAttribute.new(import_predicate: @sf_pubID_name,
                                                              value:            sfID)
                    when 1 # found it  -> skip it
                      msg = "found an existing identifier #{(i.first).to_s}"
                      warn_msg << msg
                    else # found more than 1 -> error
                      msg = "skipping - found multiple existing identifiers #{i.count} importID #{importID}"
                      error_msg << msg
                  end
                end
              end

              unless sfregID.blank?
                begin
                  i = s.data_attributes.where(import_predicate: @sf_pub_regID_name, value: sfregID)
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << ImportAttribute.new(import_predicate: @sf_pub_regID_name,
                                                              value:            sfregID)
                    when 1 # found it  -> skip it
                      msg = "found an existing identifier #{(i.first).to_s}"
                      warn_msg << msg
                    else # found more than 1 -> error
                      msg = "skipping - found multiple existing identifiers #{i.count} importID #{importID}"
                      error_msg << msg
                  end
                end
              end

              if s.valid?
                s.save
              else
                msg = "skipping -- invalid on save : tmpID #{importID} : #{s.errors.messages} "
                error_msg << msg
                # raise 's not valid'
              end
            end # end of row
            puts "\n ERRORS \n #{ap(error_msg.flatten.uniq)}\n"
            #puts "\n Warnings \n #{ap(warn_msg.flatten.uniq)}\n"
            puts 'Successful load of SF & SF registry IDs'
            # raise 'to prevent saving to db while testing rake'
          end # end transaction
        rescue
          raise
        end
      end #end task

      desc 'call like "rake tw:import:serial:serials_6_add_SF_altnames data_directory=/Users/eef/src/data/serialdata/working_data/ user_id=1 " '
      task :serials_6_add_SF_altnames => [:environment, :user_id, :data_directory ] do |t|
        file = @args[:data_directory] + 'SF_Altnames.txt' # was 'SFaltnames.txt'

        raise 'There are no existing serials, doing nothing.' if Serial.all.count == 0

        # processing third file ./SFaltnames.txt - adding additional altnames
        $stdout.sync = true
        print ('Starting transaction ...')
        error_msg = [] # array for error messages
        warn_msg  = [] # array for warnings

        begin
          ApplicationRecord.transaction do
            set_serial_import_predicates

            CSV.foreach(file,
                        headers:        true,
                        return_headers: false,
                        encoding:       'UTF-16LE:UTF-8',
                        col_sep:        "\t",
                        quote_char:     '|'
            ) do |row|

=begin
SFaltnames.txt
Column : SQL column name :  data desc
0 : ImportID : file specific import ID
1 : ShortName  : SF abbreviation
2 : SFID  : SF publication ID - check if already applied to serial
3 : SFregID  : SF publication registry ID - check if already applied to serial
=end
              importID = row[0].to_s.strip
              print ("\r  tmpID #{importID} ")
              altname = row[1].to_s.strip
              sfID    = row[2].to_s.strip
              sfregID = row[3].to_s.strip

              s  = nil
              sr = Serial.joins(:data_attributes).where(data_attributes: {value:            importID,
                                                                          import_predicate: @sf_serial_importID_name})
              case sr.count # how many serials were found for this value?
                when 0
                  msg = "skipping - unable to find base serial #{@sf_serial_importID_name} importID #{importID}"
                  error_msg << msg
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s = sr.first
                # print ("\r SerialID #{s.id} : tmpID #{importID} : shortname #{altname} : SFID #{sfID} : sfregID #{sfregID}")
                else
                  msg = "skipping - found multiple base serials #{@sf_serial_importID_name} importID #{importID}"
                  error_msg << msg
                  next
              end

              # always has a value in altname
              unless s.all_values_for(:name).include?(altname)
                begin
                  s.alternate_values << AlternateValue.new(
                    value:                            altname,
                    alternate_value_object_attribute: 'name',
                    type:                             'AlternateValue::AlternateSpelling'
                  )
                end
              end

              # check for SFID and sfReg id
              unless sfID.blank?
                begin
                  i = s.data_attributes.where(import_predicate: @sf_pubID_name, value: sfID)
                  # i = DataAttribute.where(import_predicate:     @sf_pub_id.name, attribute_subject_type: 'Serial',
                  #                         attribute_subject_id: s.id, value: sfID)
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << ImportAttribute.new(import_predicate: @sf_pubID_name,
                                                                value:            sfID)
                    when 1 # found it  -> skip it
                      msg = "found an existing identifier #{(i.first).to_s}"
                      warn_msg << msg
                    else # found more than 1 -> error
                      msg = "skipping - found multiple existing identifiers #{i.count} importID #{importID}"
                      error_msg << msg
                  end
                end
              end

              unless sfregID.blank?
                begin
                  i = ImportAttribute.where(import_predicate:       @sf_pub_regID_name,
                                          attribute_subject_type: 'Serial',
                                          attribute_subject_id:   s.id, value: sfregID)
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << ImportAttribute.new(import_predicate: @sf_pub_regID_name,
                                                              value:            sfregID)
                    when 1 # found it  -> skip it
                      msg = "found an existing identifier #{(i.first).to_s}"
                      warn_msg << msg
                    else # found more than 1 -> error
                      msg = "skipping - found multiple existing identifiers #{i.count} importID #{importID}"
                      error_msg << msg
                  end
                end
              end

              if s.valid?
                s.save
              else
                msg = "skipping -- invalid on save : tmpID #{importID} : #{ns.errors.messages} "
                error_msg << msg
              end
            end # end of row
            puts "\n#{ap(error_msg.flatten.uniq)}\n"
            #puts "\n#{ap(warn_msg.flatten.uniq)}\n"
            puts 'Successful load of SF alternate names'
            #raise 'to prevent saving to db while testing rake'
          end # end transaction
        rescue
          raise
        end
      end #end task

    end
  end
end

=begin
  SFSerialSeq.txt
  Column : SQL column name :  data desc
  0 : ImportID1 : file specific import ID  of preceding serial
  1 : ImportID2 : file specific import ID  of succeeding serial
  2 : SFregID  : SF publication registry ID of the record that created this relationship
=end
