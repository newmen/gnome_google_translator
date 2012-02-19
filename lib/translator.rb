require 'cgi'
require File.dirname(__FILE__) + '/unregistered_helpers'
require File.dirname(__FILE__) + '/localization'
require File.dirname(__FILE__) + '/config'

class Translator
  VOCABULARY_PATH = TConfig['vocabulary_dir'] + '/' + TConfig['vocabulary_file_name']
  VOCABULARY_SEPARATOR = "--\n"
  TOKENS_SEPARATOR = '-->' # be careful because it string using into regexp

  def self.run
    self.new.run
  end

  def vocabulary_hashes
    words_hash = UnregisteredHash.new
    collocation_hash = UnregisteredHash.new
    if File.exist?(VOCABULARY_PATH)
      File.open(VOCABULARY_PATH) do |voc|
        curr_hash = words_hash
        voc.readlines.each do |line|
          if line == VOCABULARY_SEPARATOR
            curr_hash = collocation_hash
            next
          end

          freq, token, transfer = line.scan(/^\[(\d+)\] (.+) #{TOKENS_SEPARATOR} (.+)$/).first
          curr_hash[token] = [transfer, freq.to_i]
        end
      end
    end
    [words_hash, collocation_hash]
  end

  def save_vocabulary(words_hash, collocation_hash)
    save_hash = lambda do |file, source_hash|
      source_arr = source_hash.map do |token, data_arr|
        transfer, freq = data_arr
        [token, transfer, freq]
      end.sort_by { |token, transfer, freq| -freq }

      source_arr.each do |token, transfer, freq|
        file << "[#{freq}] #{token} #{TOKENS_SEPARATOR} #{transfer}\n"
      end
    end

    File.open(VOCABULARY_PATH, 'w') do |voc|
      save_hash.call(voc, words_hash)
      voc << VOCABULARY_SEPARATOR
      save_hash.call(voc, collocation_hash)
    end
  end

  def get_concole_text
    text = ARGV.join(' ')
    text != '' ? text : nil
  end

  def get_x_text
    text = `xsel -o`
    text != '' ? text : nil
  end

  def prepare_text(text)
    text = text.gsub(/-\r?\n/m, '').gsub(/\r?\n/m, ' ')
    punctuation_rexp = /[\(\)\[\]\s\?\.,!:;-]+/
    text.gsub(/(^#{punctuation_rexp})|(#{punctuation_rexp}$)/, '')
  end

  def translate(text)
    text = CGI::unescape(text)
    translate_url = "http://translate.google.com/translate_a/t?client=t&text=#{text}&sl=auto&tl=ru"
    google_answer = `wget -U "Mozilla/5.0" -qO - "#{translate_url}"`
    # puts google_answer
    result = eval(google_answer.gsub(/,+/, ','))
    result ? result.flatten.first : nil
  end

  def use_vocabulary(text)
    vocabulary_is_updated = true
    find_transfer = lambda do |source_hash|
      curr_data = source_hash[text]
      if curr_data
        curr_data[1] += 1
        curr_data[0]
      else
        transfer = translate(text)
        if transfer && transfer.downcase != text.downcase && !(text.split(/\s+/).size > 5 && text.size > 21)
          source_hash[text] = [transfer, 1]
        else
          vocabulary_is_updated = false
        end
        transfer
      end
    end

    words_hash, collocation_hash = vocabulary_hashes
    result = if text !~ /\s/
      find_transfer.call(words_hash)
    else
      find_transfer.call(collocation_hash)
    end
    save_vocabulary(words_hash, collocation_hash) if result && vocabulary_is_updated

    result
  end

  def gnome_notify(message)
    `notify-send -u critical #{message}`
  end

  def run
    source_text = get_concole_text
    if source_text
      puts use_vocabulary(prepare_text(source_text))
    else
      source_text = get_x_text
      if source_text
        source_text = prepare_text(source_text)
        translated_text = use_vocabulary(source_text)
        message = %|"#{source_text}" "#{translated_text}"|
      else
        L18ze.init(TConfig['original_lang'])
        message = %|"#{L18ze['translator.source_text_does_not_selected']}"|
      end
      gnome_notify(message)
    end
  end
end
