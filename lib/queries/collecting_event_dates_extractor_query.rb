module Queries
  class CollectingEventDatesExtractorQuery # < Queries::Query
    include Arel::Nodes

    attr_accessor :collecting_event_id
    attr_accessor :filters
    attr_accessor :project_id

    # @param [Integer] collecting_event_id
    # @param [Integer] project_id
    # @param [Array] of symbolized filter names
    # @param [Object] filters
    def initialize(collecting_event_id: nil, project_id: nil, filters: [])

      collecting_event_id = 0 if collecting_event_id.nil?

      @collecting_event_id = collecting_event_id
      @filters = filters
      @project_id = project_id
    end

    # @return [String] of all of the regexs available at this time
    def filter_scopes
      if filters.blank?
        filter_keys = Utilities::Dates::REGEXP_DATES.keys.compact
      else
        filter_keys = filters
      end

      all_filters = filter_keys.collect do |kee|
        # attach 'verbatim_label ~ ' to each regex
        regex_function(kee)
      end.join(' OR ')
      # remove the names from the named groups: these don't work for sql regexs
      Arel.sql("(#{all_filters.gsub('?<year>', '').gsub('?<month>', '')})")
    end

    def where_sql
      # with_project_id.and
      # TODO: make sure you select the one of the following which suits your purpose: with or without Verbatim_lat/long preset
      (verbatim_label_not_empty).and(verbatim_date_empty).and(starting_after_id).and(filter_scopes).to_sql
      # (verbatim_label_not_empty).and(starting_after).and(filter_scopes).to_sql
    end

    def table
      CollectingEvent.arel_table
    end

    # @return [Scope]
    def all
      CollectingEvent.where(where_sql)
    end

    def verbatim_label_not_empty
      vl = Arel::Attribute.new(Arel::Table.new(:collecting_events), :verbatim_label)
      Arel::Nodes::NamedFunction.new('length', [vl]).gt(0)
    end

    def verbatim_date_empty
      Arel.sql('(verbatim_date is null)')
    end

    def starting_after_id
      start_id = Arel::Attribute.new(Arel::Table.new(:collecting_events), :id)
      start_id.gt(collecting_event_id)
    end

    # @param [String] key to FILTERS regex string
    # @return [Scope]
    def regex_function(filter)
      regex = Utilities::Dates::REGEXP_DATES[filter][:reg].to_s.gsub('(?i-mx:', '').chomp(')')
      "verbatim_label ~* '" + regex + "'"
    end

  end
end