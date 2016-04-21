# Helpers for table rendering
module Workbench::TableHelper

  def fancy_th_tag(group: nil, name: '')
    content_tag(:th, data: {group: group}) do
      content_tag(:span, name)
    end
  end

  # Hidden action links
  # data-attributes:
  #  data-show
  #  data-edit
  #  data-delete
  #
  # This is very important, it must be set to make work the options for the context menu.
  # Use the class ".table-options" to hide those options on the table
  #
  def fancy_metadata_cells_tag(object)
    m = metamorphosize_if(object)
    content_tag(:td, object_tag(object.updater)) +
      content_tag(:td, object_time_since_update_tag(object)) +
      ( defined?(m.annotated_object) ? 
       content_tag(:td, (link_to 'Show', metamorphosize_if(m.annotated_object)), class: 'table-options', data: {show: true}) :
       content_tag(:td, (link_to 'Show', m), class: 'table-options', data: {show: true})
      ) + 
      content_tag(:td, edit_object_link(object), class: 'table-options', data: {edit: true}) + 
      content_tag(:td, (link_to 'Destroy', m, method: :delete, data: {confirm: 'Are you sure?'}), class: 'table-options', data: {delete: true})
  end

end