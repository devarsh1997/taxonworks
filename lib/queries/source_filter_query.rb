module Queries

  class SourceFilterQuery < Queries::Query

    include Arel::Nodes

    def cached
      table[:cached].matches_any(strings)
    end

    def where_sql
      cached.or(with_id).to_sql
    end
    
    def year
      if !years.empty?
        table[:year].eq_any(years) 
      else
        table[:id].eq('-1').not
      end
    end

    def cached_full_match
      if no_digits.blank?
        table[:id].eq('-1')
      else
        table[:cached].matches("%#{no_digits}%")
      end
    end

    # !! needs major refactoring, thought
    # @return [Array]
    def all 
      ( 
       [ Source.find_by_cached(query_string) ]  +
       Source.where(cached_full_match.and(year).to_sql).limit(200) +
       Source.where(with_id.to_sql).limit(200) +
       Source.where(cached.and(year).to_sql).limit(200) +
       Source.where(cached.to_sql).limit(200)  
      ).flatten.compact.uniq
    end

    def by_project_all
      ( 
       [ Source.joins(:project_sources).where(member_of_project_id.to_sql).find_by_cached(query_string) ]  +
       Source.joins(:project_sources).where(member_of_project_id.to_sql).where(cached_full_match.and(year).to_sql).limit(20) +
       Source.joins(:project_sources).where(member_of_project_id.to_sql).where(with_id.to_sql).limit(20) +
       Source.joins(:project_sources).where(member_of_project_id.to_sql).where(cached.and(year).to_sql).limit(30) +
       Source.joins(:project_sources).where(member_of_project_id.to_sql).where(cached.to_sql).limit(40)  
      ).flatten.compact.uniq
    end

    def table
      Source.arel_table
    end

    def project_sources_table
      ProjectSource.arel_table
    end

    def member_of_project_id
      project_sources_table[:project_id].eq(project_id)
    end

  end
end