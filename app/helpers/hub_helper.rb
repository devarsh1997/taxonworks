module HubHelper

  # TODO FIX ON Turbolinks 5.0
  def task_card(task)
    content_tag(:div, '', class: 'task_card') { 
      link_to(content_tag(:div,
        content_tag(:div,'' , class: "task_header status #{task.status}") {
          content_tag(:div, '') {
            task.categories.collect{|c| 
              content_tag(:div, c.humanize, class: "categories #{c}", "data-category-#{c}" => "true", "data-category-#{task.status}" => "true" )
            }.join().html_safe 
          } 
        } +      
        content_tag(:div, '', class: 'task-information') {
          content_tag(:div, task.name, class: 'task_name') +
          content_tag(:div, task.description, class: 'task_description') 
        }
      ),send(task.path), data: { turbolinks: false }) +
      content_tag(:div, '', class: 'fav-link') {
            favorite_page_link('tasks', task.prefix) 
      }       
    }
  end

  def data_link(data)
    link_to(data.name, data.klass)
  end

  def data_card(data)
    content_tag(:div, class:  ['data_card', data.shared_css, data.application_css].flatten.join(' ')) do  
      content_tag(:div, "", 
                  data.categories.inject({}){|hsh,c| hsh.merge!("data-category-#{c}" => "true") }.merge(class: [:filter_data, "#{data.status}"], "data-category-#{data.status}" => "true")
                 ) + 
        data_link(data) 
    end
  end

end

