module Extensions
  EXTENSIONS_PATH = "#{Rails.root}/lib/extensions"

  def self.load_all
    Dir[EXTENSIONS_PATH + '/*.rb'].each do |ext|
      require ext
    end
  end
end
