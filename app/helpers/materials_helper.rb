module MaterialsHelper
  def get_pretty_file_size(size_in_bytes)
    suffixes = ["B", "KB", "MB", "GB"]
    size = size_in_bytes
    size_current_units = size_in_bytes
    unit = 0
    while size_current_units > 1024 and unit < suffixes.length do
      size_current_units = size_current_units / 1024.0
      unit += 1
    end
    size_rounded = sprintf "%.2f", size_current_units
    size_rounded + " " + suffixes[unit]
  end

  def get_materials_display_name
    preferable = @course.student_sidebar_items.joins(:preferable_item).
      where(preferable_items: {name: 'materials'}).first
    preferable.prefer_value
  end
end
