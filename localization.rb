require 'i18n'

module Localization
  def localization_init(short_locale)
    I18n.load_path << Dir['config/locales/*.yml']
    I18n.locale = short_locale
  end

  def t(*args)
    puts I18n.t(args)
  end
end
