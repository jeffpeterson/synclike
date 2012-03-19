module ApplicationHelper
  def set_title title
    @title = title
    content_tag :h2, title
  end
  
  def full_title
    base_title = "synclike"
    if @title
      "#{base_title} | #{@title}"
    else
      base_title
    end
  end
end
