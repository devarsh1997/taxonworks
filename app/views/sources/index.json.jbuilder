json.array!(@sources) do |source|
  json.extract! source, :id, :serial_id, :address, :annote, :author, :booktitle, :chapter, :crossref, :edition, :editor, :howpublished, :institution, :journal, :key, :month, :note, :number, :organization, :pages, :publisher, :school, :series, :title, :type, :volume, :doi, :abstract, :copyright, :language, :stated_year, :verbatim, :cached, :cached_author_string, :bibtex_type, :created_by_id, :updated_by_id, :nomenclature_date, :day, :year, :isbn, :issn, :verbatim_contents, :verbatim_keywords, :language_id, :translator, :year_suffix, :url
  json.url source_url(source, format: :json)
end
