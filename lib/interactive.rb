module Interactive
  def enter_value(message, default_value)
    print "#{message} [#{default_value}]: "
    value = gets.chomp
    value == '' ? default_value : value
  end

  def yes_no_value(message)
    answer = enter_value(message, 'Yn')
    answer.downcase[0] == 'y'
  end
end