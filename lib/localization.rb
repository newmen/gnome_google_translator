require 'i18n'

class L18ze
  PATH_TO_LOCALES = '../config/locales'
  DEFAULT_LOCALE = 'en'

  def self.[](*args)
    I18n.translate(*args)
  end

  def self.init(locale)
    unless @locale_files_list
      @locale_files_list = Dir[File.dirname(__FILE__) + '/' + PATH_TO_LOCALES + '/*.yml']
      I18n.load_path << @locale_files_list
    end
    locales_list = @locale_files_list.map { |file_name| File.basename(file_name, '.yml') }
    I18n.locale = locales_list.include?(locale) ? locale : DEFAULT_LOCALE
  end
end
