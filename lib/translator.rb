require 'cgi'
require File.dirname(__FILE__) + '/unregistered_helpers'
require File.dirname(__FILE__) + '/localization'
require File.dirname(__FILE__) + '/config'

class Translator
  TOKENS_SEPARATOR = '-->' # be careful because it string using into regexp
  WORDS_SEPARATOR = ' %% '
  VOCABULARY_SEPARATOR = "--\n"
  VOCABULARY_PATH = TConfig['vocabulary_dir'] + '/' + TConfig['vocabulary_file_name']
  CACHED_VOCABULARY_PATH = '../cache/' + TConfig['vocabulary_file_name']
  ICON_PATH = File.dirname(__FILE__) + '/../config/google-translate.png'

  def self.run
    L18ze.init(TConfig['original_lang'])

    if ARGV.first == '--help'
      puts L18ze['translator.help']
    else
      self.new(!!(ARGV.delete('--original'))).run
    end
  end

  def initialize(translate_from_original_lang)
    @is_original_lang = translate_from_original_lang
  end

  def run
    source_text = get_concole_text
    if source_text
      puts use_vocabulary(prepare_text(source_text)).join("\n")
    else
      source_text = get_x_text
      if source_text
        source_text = prepare_text(source_text)
        translated_text = use_vocabulary(source_text)
        message = %|"#{source_text}" "#{translated_text.join("\n")}"|
      else
        message = %|"#{L18ze['translator.source_text_does_not_selected']}"|
      end
      gnome_notify(message)
    end

    clear_vocabulary_if_need
  end

  private

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
          curr_hash[token] = [transfer.split(WORDS_SEPARATOR), freq.to_i]
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
        file << "[#{freq}] #{token} #{TOKENS_SEPARATOR} #{transfer.join(WORDS_SEPARATOR)}\n"
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
    punctuation_rexp = /[\s,:;-]+/
    text.gsub!(/(^#{punctuation_rexp})|(#{punctuation_rexp}$)/, '')
    text.gsub!(/^[\)\]\?\.!]/, '')
    text.gsub!(/[\(\[]$/, '')
    text
  end

  def translate(text)
    #puts "ORIGINAL TEXT: #{text}"
    text = CGI::unescape(text)
    from_to = "sl=auto&tl=#{TConfig[(@is_original_lang ? 'alternate_lang' : 'original_lang')]}"
    translate_url = "http://translate.google.com/translate_a/t?client=t&text=#{text}&#{from_to}"
    google_answer = `wget -U "Mozilla/5.0" -qO - "#{translate_url}"`
    #puts "GOOGLE ANSWER: #{google_answer}"
    commons, details = eval(google_answer.gsub(/,{2,}/, ','))
    if details.is_a?(String)
      result = commons.map { |phrases| phrases.first }
    else # if details.is_a?(Array)
      result = []
      details.each { |part| result.concat(part[1]) }
    end
    #puts "RESULT: #{result.inspect}"
    result[0..12]
  end

  def use_vocabulary(text)
    vocabulary_is_updated = true
    find_transfer = lambda do |source_hash|
      stored_translate_data = source_hash[text]
      if stored_translate_data
        stored_translate_data[1] += 1
        stored_translate_data[0]
      else
        transfer = translate(text)
        if transfer.first && transfer.first.downcase != text.downcase && !(text.split(/\s+/).size > 5 && text.size > 21)
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

  def clear_vocabulary_if_need
    get_file_lines = lambda { |file_path|
      File.open(file_path) { |f| f.readlines }
    }

    save_file = lambda { |file_path, lines|
      File.open(file_path, 'w') { |f| f << lines.join }
    }

    cached_vocabulary_path = File.dirname(__FILE__) + '/' + CACHED_VOCABULARY_PATH
    save_cache = lambda { |lines|
      translates = lines - [VOCABULARY_SEPARATOR]
      save_file.call(cached_vocabulary_path, translates)
    }

    unless File.exist?(cached_vocabulary_path)
      cache_dir = File.dirname(cached_vocabulary_path)
      Dir.mkdir(cache_dir) unless File.exist?(cache_dir)
      save_cache.call(get_file_lines.call(VOCABULARY_PATH))
      return
    end

    cache_time = File.mtime(cached_vocabulary_path).to_i
    return if cache_time + TConfig['how_often_to_clean'].to_i * 86400 > Time.now.to_i

    diff = get_file_lines.call(VOCABULARY_PATH) - get_file_lines.call(cached_vocabulary_path)
    save_file.call(VOCABULARY_PATH, diff)
    save_cache.call(diff)
  end

  def gnome_notify(message)
    `notify-send -u critical --icon=#{ICON_PATH} #{message}`
  end
end
