# coding: utf-8

require 'cgi'

VOCABULARY_PATH = ENV['VOCABULARY_DIR'] + '/' + ENV['VOCABULARY_FILE_NAME']
VOCABULARY_SEPARATOR = "--\n"
TOKENS_SEPARATOR = '-->' # будьте осторожны, ибо эта штука используется в регулярном выражении

class UnregisteredString
	attr_reader :str
	def initialize(str); @str = str end

	def <=>(other)
		@str.downcase <=> other.str.downcase
	end

	def ==(other); self.<=>(other) == 0 end
	def eql?(other); self.==(other) end
	def hash; @str.downcase.hash end
	def to_s; @str end
end

class UnregisteredHash < Hash
	def [](key)
		key.is_a?(String) ? super(UnregisteredString.new(key)) : super
	end

	def []=(key, value)
		key.is_a?(String) ? super(UnregisteredString.new(key), value) : super
	end
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
	find_transfer = lambda do |source_hash|
		curr_data = source_hash[text]
		if curr_data
			curr_data[1] += 1
			curr_data[0]
		else
			transfer = translate(text)
			source_hash[text] = [transfer, 1] if transfer && transfer.downcase != text.downcase
			transfer
		end
	end

	words_hash, collocation_hash = vocabulary_hashes
	result = if text !~ /\s/
		find_transfer.call(words_hash)
	else
		find_transfer.call(collocation_hash)
	end
	save_vocabulary(words_hash, collocation_hash) if result

	result
end

def main
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
			message = '"Не выделили текст для перевода"'
		end
		`notify-send -u critical #{message}`
	end
end

main
