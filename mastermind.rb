# frozen_string_literal: false

# An addon to the String class to change the colour of the text
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
end

# An item represented by one number within any given four digit code
class CodeItem
  attr_accessor :number, :color_code

  def initialize(number)
    @number = number
    @color_code = get_color_code(number)
  end

  def display_item
    @number.colorize(@color_code)
  end

  private

  def get_color_code(number)
    color_codes = { '1' => 45, '2' => 46, '3' => 41, '4' => 44, '5' => 42, '6' => 43 }
    color_codes[number.to_s]
  end
end

# The class for creating a new game
class Game
  def initialize(game_mode)
    if game_mode == '1'
      start_breaker
    else
      start_maker
    end
  end

  def display_code(code)
    code.each { |code_item| print "|#{"   #{code_item.number}   ".colorize(code_item.color_code).colorize(1)}" }
    puts ' '
  end

  private

  def start_breaker
    generate_code

    puts 'The secret code has been set, you now have 12 attempts to break the code, good luck!'

    display_code(@secret_code)
  end

  def start_maker
    puts "Computer says: You're the code maker and I broke your code!!"
  end

  def generate_code
    @secret_code = []
    4.times do
      code_item = CodeItem.new(rand(1..6))
      @secret_code.push(code_item)
    end
  end
end

puts ' '
puts "                         *** #{'Welcome to Mastermind!'.colorize(4)} ***               "
puts ' '
puts 'Mastermind is a code-breaking game for two players. In this case, you and the computer.'
puts ' '
puts 'You will have the choice to be the code maker or the code breaker. As the code maker, you'
puts 'will define the code that the computer will then attempt to break.  As the code breaker,'
puts 'the computer will set the code, which you then have to break. The code breaker is required'
puts 'to complete the task within 12 attempts!'
puts ' '
puts 'After each attempt, the code breaker is given clues as follows:'
puts "#{"\u2022".encode('UTF-8').colorize(31)} - Indicates that the correct colour is selected"\
' and that it is in the right spot.'
puts "#{"\u2022".encode('UTF-8')} - Indicates that the correct colour is selected but that colour"\
' is in the wrong location.'
puts ' '
puts 'Please enter \'1\' if would like to be the code breaker of \'2\' if you would like to be the'
puts 'code maker'

game_mode = gets.chomp
puts ' '

Game.new(game_mode)
