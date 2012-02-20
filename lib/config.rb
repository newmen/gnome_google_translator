require 'yaml'
require File.dirname(__FILE__) + '/interactive'
require File.dirname(__FILE__) + '/localization'

class TConfig
  include Interactive

  PATH_TO_CONFIG_FILE = '../config/config.yml'
  LANGS = %w|af ar az be bg bn ca cs cy da de el en es et eu fa fi fr ga gl gu hi hr ht hy hy id is it iw ja ka kn ko la lt lv mk ms mt nl no pl pt ro ru sk sl sq sr sv sw ta te th tl tr uk ur vi yi zh-CH|

  DEFAULT_ALTERNATE_LANG = 'en'
  DEFAULT_VOCABULARY_DIR = ENV['HOME']
  DEFAULT_VOCABULARY_FILE_NAME = 'vocabulary.txt'
  DEFAULT_HOW_OFTEN_TO_CLEAN = 5

  def self.setup
    self.new.setup
  end

  def self.[](key)
    @config ||= self.new
    @config.hash[key]
  end

  attr_reader :hash

  def initialize
    @hash = File.exist?(full_path) ? YAML.load_file(full_path) : {}
  end

  def setup
    ask_and_setup_lang

    lambda_ask = lambda { |var_name|
      old_value = @hash[var_name] || eval("DEFAULT_#{var_name.upcase}")
      @hash[var_name] = enter_value(L18ze['config.' + var_name], old_value)
    }

    lambda_ask.call('alternate_lang')
    lambda_ask.call('vocabulary_dir')
    lambda_ask.call('vocabulary_file_name')
    lambda_ask.call('how_often_to_clean')

    save
  end

  private

  def ask_and_setup_lang
    original_lang = @hash['original_lang'] || L18ze::DEFAULT_LOCALE
    L18ze.init(original_lang)
    lang = nil
    loop do
      lang = if lang
        enter_value(L18ze['config.bad_lang'], original_lang)
      else
        enter_value(L18ze['config.select_lang', langs: LANGS.join(', ')], original_lang)
      end

      break if LANGS.include?(lang)
    end
    L18ze.init(lang) if original_lang != lang
    @hash['original_lang'] = lang
  end

  def save
    File.open(full_path, 'w') do |config_file|
      YAML.dump(@hash, config_file)
    end
  end

  def full_path
    File.dirname(__FILE__) + '/' + PATH_TO_CONFIG_FILE
  end
end
