# Helpers that wrap sets of annotations of different types.
module AnnotationsHelper 

  # @return [String]
  # Assumes the context is the object, not a multi-object summary
  def annotations_summary_tag(object)
    content_tag(:div, class: %w{item panel separate-left separate-right separate-bottom}) do
      content_tag(:div, class: [:content]) do
        content_tag(:span, '*', id: annotation_id(object), data: {annotation_anchor: true}) + # Radial fly out annotator, float right
          content_tag(:div, class: ['information-panel']) do
          content_tag(:h2, 'Annotations') +
            [citation_list_tag(object),
             identifier_list_tag(object), 
             data_attribute_list_tag(object), 
             note_list_tag(object), 
             tag_list_tag(object),
             alternate_values_list_tag(object)
          ].compact.join.html_safe

        end
      end
    end

    # depictions
    # confidences
    # protocols

  end

  def annotation_id(object)
    "annotation_anchor_#{object.metamorphosize.class.name}_#{object.id}"
  end


end
