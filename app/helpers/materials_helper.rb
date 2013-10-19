module MaterialsHelper
  def get_file_size_suffix(size_in_bytes)
    suffixes = ["B", "KB", "MB", "GB"]
    size = size_in_bytes
    i = 0
    while size > 1 and i < suffixes.length do
      size = size / 1024
      i += 1
    end
    suffixes[i]
  end
end