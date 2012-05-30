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
    STDERR << L18ze['installer.translator_file_not_found', translator_file_path: translator_file_path] + "\n"
    exit!
  end

  def create_bin
    Dir.mkdir(bin_dir) unless File.exist?(bin_dir)

    if File.exist?(translator_bin_path)
      return -1 unless yes_no_value(L18ze['installer.translator_bin_exist', translator_bin_path: translator_bin_path])
      result = 1
    else
      result = 0
    end

    File.open(translator_bin_path, 'w') do |f|
      f << Template['translate.sh', translator_file_path: translator_file_path]
    end

    File.chmod(0755, translator_bin_path)
    result
  end

  def prepare_hotkey(hotkey)
    keys = hotkey.split('+')
    last_key = keys.pop
    keys.map do |key|
      key = 'Mod4' if key == 'Win'
      "&lt;#{key}&gt;"
    end.join + last_key
  end

  # TODO: need replace below method for using gconftool-2
  def create_hotkey(hotkey, translator_key_option = nil)
    check_dir_exist = lambda do |dir|
      unless File.exist?(dir)
        puts L18ze['installer.ask_about_gnome']
        exit!
      end
    end

    keybindings_dir = HOME_DIR + '/.gconf'
    check_dir_exist.call(keybindings_dir)
    keybindings_dir << '/desktop'
    check_dir_exist.call(keybindings_dir)
    keybindings_dir << '/gnome'
    check_dir_exist.call(keybindings_dir)
    keybindings_dir << '/keybindings'

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
    path = translator_bin_path
    path += ' ' + translator_key_option if translator_key_option
    File.open(hotkey_conf_path, 'w') do |f|
      time = Time.now.to_i
      f << Template['hotkey.xml', time: time, translator_bin_path: path, hotkey: prepare_hotkey(hotkey)]
    end
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
    return unless yes_no_value(L18ze['installer.ask_create_hotkeys', another_lang_hotkey: ANOTHER_LANG_HOTKEY, original_lang_hotkey: ORIGINAL_LANG_HOTKEY])

    create_hotkey(ANOTHER_LANG_HOTKEY)
    create_hotkey(ORIGINAL_LANG_HOTKEY, '--original')
    puts L18ze['installer.hotkeys_created']
    puts L18ze['installer.need_gnome_restart']
  end
end
