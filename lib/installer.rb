require File.dirname(__FILE__) + '/interactive'
require File.dirname(__FILE__) + '/template'
require File.dirname(__FILE__) + '/config'

class Installer
  include Interactive

  TRANSLATOR_FILE_NAME = 'translate.rb'
  TRANSLATOR_BIN_NAME = 'translate'

  ANOTHER_LANG_HOTKEY = 'Alt+F9'
  ORIGINAL_LANG_HOTKEY = 'Alt+Win+F9'

  HOME_DIR = ENV['HOME']
  CURRENT_DIR = File.expand_path(File.dirname(__FILE__) + '/..')
  # RUBY_PATH = File.expand_path(`which ruby`) #.gsub(/^~/, home_dir)

  def self.run
    self.new.run
  end

  def bin_dir
    HOME_DIR + '/bin'
  end

  def translator_file_path
    CURRENT_DIR + '/' + TRANSLATOR_FILE_NAME
  end

  def translator_bin_path
    bin_dir + '/' + TRANSLATOR_BIN_NAME
  end

  def check_translator_file_exist
    return if File.exist?(translator_file_path)
    STDERR << L18ze['installer.translator_file_not_found', {:translator_file_path => translator_file_path}] + "\n"
    exit!
  end

  def create_bin
    Dir.mkdir(bin_dir) unless File.exist?(bin_dir)

    if File.exist?(translator_bin_path)
      return -1 unless yes_no_value(L18ze['installer.translator_bin_exist', {:translator_bin_path => translator_bin_path}])
      result = 1
    else
      result = 0
    end

    File.open(translator_bin_path, 'w') do |f|
      f << Template['translate.sh', {:translator_file_path => translator_file_path}]
    end

    File.chmod(0755, translator_bin_path)
    result
  end

  def prepare_hotkey(hotkey)
    keys = hotkey.split('+')
    last_key = keys.pop
    keys.map do |key|
      key = 'Mod4' if key == 'Win'
      "<#{key}>"
    end.join + last_key
  end

  def create_hotkey(hotkey, translator_key_option = nil)
    run_command_path_lambda = lambda { |num| "/apps/metacity/global_keybindings/run_command_#{num}" }
    command_path_lambda = lambda { |num| "/apps/metacity/keybinding_commands/command_#{num}" }

    gconftool_get_lambda = lambda { |path| `gconftool-2 --get #{path}`.strip }
    find_empty_command_lambda = lambda {
      empty_command_num = 0
      (1..12).each do |num|
        next unless gconftool_get_lambda.call(run_command_path_lambda.call(num)) == 'disabled'
        next unless gconftool_get_lambda.call(command_path_lambda.call(num)) == ''

        empty_command_num = num
        break
      end
      empty_command_num
    }

    command_num = find_empty_command_lambda.call
    if command_num == 0
      # TODO: use a more informative message
      puts L18ze['installer.ask_about_gnome']
      exit!
    end

    gconftool_set_lambda = lambda { |path, value| `gconftool-2 --type=string --set #{path} '#{value}'` }
    path = translator_bin_path
    path += ' ' + translator_key_option if translator_key_option
    gconftool_set_lambda.call(run_command_path_lambda.call(command_num), prepare_hotkey(hotkey))
    gconftool_set_lambda.call(command_path_lambda.call(command_num), path)
  end

  def run
    TConfig.setup

    check_translator_file_exist
    result = create_bin

    print "#{HOME_DIR + '/bin/' + TRANSLATOR_BIN_NAME} "
    puts case(result)
    when -1 then L18ze['installer.translator_bin_not_replaced']
    when 0 then L18ze['installer.translator_bin_created']
    when 1 then L18ze['installer.translator_bin_replaced']
    end

    return unless result == 0
    return unless yes_no_value(L18ze['installer.ask_create_hotkeys', {:another_lang_hotkey => ANOTHER_LANG_HOTKEY, :original_lang_hotkey => ORIGINAL_LANG_HOTKEY}])

    create_hotkey(ANOTHER_LANG_HOTKEY)
    create_hotkey(ORIGINAL_LANG_HOTKEY, '--original')
    puts L18ze['installer.hotkeys_created']
  end
end
