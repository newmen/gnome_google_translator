# coding: utf-8

# THIS FILE IS DEPRECATED

require 'fileutils'

def clear
  old_translator_path = ENV['HOME'] + '/bin/translator'
  return unless File.exist?(old_translator_path)
  FileUtils.rm_f(old_translator_path)

  keybindings_dir = ENV['HOME'] + '/.gconf/desktop/gnome/keybindings'
  return unless File.exist?(keybindings_dir)

  inner_dirs = Dir.entries(keybindings_dir) - ['.', '..', '%gconf.xml']
  if inner_dirs.size > 1
    puts 'Невозможно самостоятельно удалить старый Hotkey. Удалите его пожалуйста вручную и повторите установку.'
    exit!
  end

  FileUtils.rm_rf(keybindings_dir)
end
