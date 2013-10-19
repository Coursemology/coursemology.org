module MaterialsHelper
  def human_file_size(size_in_bytes)
    suffixes = ["B", "KB", "MB", "GB"]
    size = size_in_bytes
    i = 0
    while size > 1024 and i < suffixes.length do
      size /= 1024
      i += 1
    end
    "#{size} #{suffixes[i]}"
  end
end