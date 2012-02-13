# coding: utf-8

TRANSLATOR_FILE_NAME = 'translator.rb'
TRANSLATOR_BIN_NAME = 'translator'

VOCABULARY_DEFAULT_FILE_NAME = 'vocabulary.txt'

HOME_DIR = ENV['HOME']
CURRENT_DIR = File.expand_path(File.dirname(__FILE__))
# RUBY_PATH = File.expand_path(`which ruby`) #.gsub(/^~/, home_dir)

def bin_dir
	HOME_DIR + '/bin'
end

def translator_file_path
	CURRENT_DIR + '/' + TRANSLATOR_FILE_NAME
end

def translator_bin_path
	bin_dir + '/' + TRANSLATOR_BIN_NAME
end

def enter_value(message, default_value)
	print "#{message} [#{default_value}]: "
	value = gets.chomp
	value == '' ? default_value : value
end

def yes_no_value(message)
	answer = enter_value(message, 'Yn')
	answer.downcase[0] == 'y'
end

def check_translator_file_exist
	return if File.exist?(translator_file_path)
	STDERR << "Почему-то нет скрипта осуществляющего перевод (#{translator_file_path}). WTF?\n"
	exit!
end

def create_bin
	Dir.mkdir(bin_dir) unless File.exist?(bin_dir)
	
	if File.exist?(translator_bin_path)
		return -1 unless yes_no_value("Файл #{translator_bin_path} уже существует. Заменить?")
		result = 1
	else
		result = 0
	end

	vocabulary_dir = enter_value('Укажите директорию, для файла словаря', HOME_DIR)
	vocabulary_file_name = enter_value('Укажите название файла словаря', VOCABULARY_DEFAULT_FILE_NAME)

	File.open(translator_bin_path, 'w') do |f|
		f << <<-CONTENT
#!/bin/sh

export VOCABULARY_DIR='#{vocabulary_dir}'
export VOCABULARY_FILE_NAME='#{vocabulary_file_name}'

ruby #{translator_file_path} $@
		CONTENT
	end

	File.chmod(0755, translator_bin_path)
	result
end

def create_hotkey
	check_dir_exist = lambda do |dir|
		unless File.exist?(dir)
			puts "Может быть у вас не Gnome?"
			exit!
		end
	end

	keybindings_dir = HOME_DIR + '/.gconf'
	check_dir_exist.call(keybindings_dir)
	keybindings_dir += '/desktop'
	check_dir_exist.call(keybindings_dir)
	keybindings_dir += '/gnome'
	check_dir_exist.call(keybindings_dir)
	keybindings_dir += '/keybindings'
	
	unless File.exist?(keybindings_dir)
		Dir.mkdir(keybindings_dir)
		File.open(keybindings_dir + '/%gconf.xml', 'w') {}
	end

	custom_dirs = Dir.entries(keybindings_dir) - ['.', '..', '%gconf.xml']
	curr_number = custom_dirs.size
	lambda_custom_dir = lambda { keybindings_dir + '/custom' + curr_number.to_s }
	while File.exist?(lambda_custom_dir.call)
		curr_number += 1
	end

	Dir.mkdir(lambda_custom_dir.call)
	hotkey_conf_path = lambda_custom_dir.call + '/%gconf.xml'
	File.open(hotkey_conf_path, 'w') do |f|
		time = Time.now.to_i
		f << <<-CONTENT
<?xml version="1.0"?>
<gconf>
	<entry name="action" mtime="#{time}" type="string">
		<stringvalue>#{translator_bin_path}</stringvalue>
	</entry>
	<entry name="name" mtime="#{time}" type="string">
		<stringvalue>Translate notify</stringvalue>
	</entry>
	<entry name="binding" mtime="#{time}" type="string">
		<stringvalue>&lt;Alt&gt;F9</stringvalue>
	</entry>
</gconf>
	CONTENT
	end
end

def main
	check_translator_file_exist
	result = create_bin

	print "#{HOME_DIR + '/bin/' + TRANSLATOR_BIN_NAME} "
	puts case(result)
	when -1 then "не заменён"
	when 0 then "успешно создан"
	when 1 then "успешно заменён"
	end

	return unless result == 0
	return unless yes_no_value("Прописать Hotkey Alt+F9?")

	create_hotkey
	puts "Hotkey прописан"
	puts "Чтобы изменения вступили в силу, перезапустите Gnome"
end

main
