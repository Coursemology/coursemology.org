# Service object to help with PDF to PNG file conversion
# Needs the poppler-utils package to be installed
#
class PngConvert
  # uploaded_file_object should be a PDF file uploaded using ruby forms
  def initialize(uploaded_file_object)
    @uploaded_file_object = uploaded_file_object

    # strip out the file extension
    @basename = File.basename(sanitize_filename(uploaded_file_object.original_filename), '.pdf')

    write_to_pdf
  end

  # generate and run the conversion command
  # each page in the PDF file results in 1 PNG file
  # returns the list of PNG files generated
  def convert_to_png
    convert_cmd = "/usr/bin/pdftoppm -png -r 300 #{@pdf_filename} #{@basename}"
    `#{convert_cmd}`

    # return list of png files from conversion
    @png_files = Dir[ "#{@basename}*.png" ]

    # sort files by name and return
    @png_files.sort
  end

  # call this when you are done processing the PNG files
  def clean_up
    #delete PDF file when done
    File.delete(@pdf_filename)

    # clean up PNG files on filesystem
    @png_files.each do |png_file|
      File.delete(png_file)
    end
  end

  private

  def write_to_pdf
    # generate a random filename
    @pdf_filename = SecureRandom.hex
    File.open(@pdf_filename, 'wb') do |file|
      file.write(@uploaded_file_object.read)
    end
  end

  # from ruby on rails security guide, which in turn got it from the
  # attachment_fu plugin
  def sanitize_filename(filename)
    filename.strip.tap do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.sub! /\A.*(\\|\/)/, ''
      # Finally, replace all non alphanumeric, underscore
      # or periods with underscore
      name.gsub! /[^\w\.\-]/, '_'
    end
  end

end
