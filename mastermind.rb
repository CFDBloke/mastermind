# frozen_string_literal: false

# An addon to the String class to change the colour of the text
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def integer?
    /\A[-+]?\d+\z/.match?(self)
  end
end

# An item represented by one number within any given four digit code
class CodeItem
  attr_accessor :number, :color_code, :clue

  def initialize(number)
    @number = number
    @color_code = get_color_code(number)
    @clue = CodeClue.new
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

class CodeClue
end

# The class for displaying the gameboard
class GameBoard
  def draw_board(guesses, max_guesses)
    draw_header
    puts '|====================================================|'

    draw_guesses(guesses)

    draw_blank(max_guesses, guesses.length)

    puts '|====================================================|'
  end

  def display_code(code)
    code.each { |code_item| print "|#{"   #{code_item.number}   ".colorize(code_item.color_code).colorize(1)}" }
    print ''
  end

  private

  def draw_header
    puts '|====================================================|'
    puts '| Turn ||           Guesses             ||   Clues   |'
  end

  def draw_guesses(guesses)
    guesses.each do |guess_number, guess|
      print "|  #{guess_number}#{Integer(guess_number) < 10 ? ' ' : ''}  |"
      print display_code(guess)
      print '||           |'
      puts ''
      puts '|----------------------------------------------------|'
    end
  end

  def draw_blank(max_guesses, number_of_guesses)
    start_number = number_of_guesses + 1
    (max_guesses - number_of_guesses).times do
      puts "|  #{start_number}#{Integer(start_number) < 10 ? ' ' : ''}  ||       |       |       |       ||           |"
      puts '|----------------------------------------------------|'
      start_number += 1
    end
  end
end

# The class for creating a new game
class Game
  def initialize(game_mode)
    @guess_number = '1'
    @guesses = {}
    @max_guesses = 12
    @solved = false
    @gameboard = GameBoard.new
    if game_mode == '1'
      start_breaker
    else
      start_maker
    end
  end

  private

  def start_breaker
    generate_code

    puts 'When prompted, enter your first code guess by typing in four digits representing the different colours.'
    puts 'For example 1234, then press enter to log your guess and get the clues returned to you'

    puts 'The secret code has been set, you now have 12 attempts to break the code, good luck!'

    @gameboard.display_code(@secret_code)

    request_guess until @solved || @guess_number == @max_guesses
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

    @secret_string = @secret_code.reduce('') { |str, item| str + item.number.to_s }
  end

  def log_guess(guess)
    @guesses[@guess_number] = codify(guess)
    @guess_number = (@guess_number.to_i + 1).to_s
    @solved = guess == @secret_string
  end

  def codify(guess)
    guess_codes = []
    guess.split('').each { |number| guess_codes.push(CodeItem.new(Integer(number))) }
    guess_codes
  end

  def request_guess
    puts "\nPlease enter guess number #{@guess_number}:"
    guess = gets.chomp
    puts ''

    if valid_guess?(guess)
      log_guess(guess)
    else
      puts 'That guess is not valid, please try again'
      request_guess
    end

    @gameboard.draw_board(@guesses, @max_guesses)
  end

  def valid_guess?(guess)
    guess_array = guess.split('')

    return unless guess_array.length == 4

    guess_array.all? { |num| num.integer? && Integer(num) >= 1 && Integer(num) <= 6 }
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
