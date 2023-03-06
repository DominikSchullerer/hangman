# frozen_string_literal: true

# Rules class handles the game mechanics
class Rules
  def self.updated_word_string(word, correct_letters)
    word_string = ''

    word.each_char do |char|
      word_string +=  if correct_letters.include?(char)
                        "#{char} "
                      else
                        '_ '
                      end
    end
    word_string
  end

  def self.correct_letter?(word, char)
    word.include?(char)
  end

  def self.guess_is_valid?(char, guessed_letters)
    valid = true
    valid = false unless char.match?(/\A[A-Z]\z/)
    valid = false if guessed_letters.include?(char)
    valid
  end

  def self.gamestate(word, word_string, wrong_letters)
    gamestate = 'playing'

    gamestate = 'lost' if wrong_letters.length == 6
    gamestate = 'won' if word == word_string.gsub(' ', '')

    gamestate
  end
end

# GM class manages the game flow
class GM
  attr_accessor :board

  def initialize
    @word_list = File.readlines('resources/word_list.txt', chomp: true)
  end

  def random_word
    @word_list[rand(@word_list.length)].upcase
  end

  def new_game
    @player = Player.new
    @board = Board.new
    @board.word = random_word
    @board.word_string = ''.rjust(2 * @board.word.length, '_ ')
    game_loop
  end

  def handle_guess(char)
    if Rules.correct_letter?(@board.word, char)
      @board.correct_letters << char
    else
      @board.wrong_letters << char
    end

    @board.word_string = Rules.updated_word_string(@board.word, @board.correct_letters)
    @board.draw_board
  end

  def game_loop
    gamestate = 'playing'

    @board.draw_board
    while gamestate == 'playing'
      guess = @player.player_guess
      handle_guess(guess)
      @board.draw_board
      gamestate = Rules.gamestate(@board.word, @board.word_string, @board.wrong_letters)
    end

    @board.put_final_message(gamestate)
  end
end

# Board class stores and displays the game state
class Board
  attr_accessor :word, :word_string, :correct_letters, :wrong_letters, :guessed_letters

  def initialize(word = nil, wrong_letters = [], correct_letters = [])
    @word = word
    @wrong_letters = wrong_letters
    @correct_letters = correct_letters
  end

  def draw_hangman(errors)
    File.open("resources/hangman_stages/#{errors}_error.txt") do |file|
      puts file.readlines
    end
  end

  def draw_board
    puts '_______________________________________'
    draw_hangman(@wrong_letters.length)
    puts @word
    puts @word_string
    print 'Wrong letters: '
    @wrong_letters.each { |char| print "#{char} " }
    puts ''
    print 'Correct letters: '
    @correct_letters.each { |char| print "#{char} " }
    puts ''
  end

  def put_final_message(gamestate)
    case gamestate
    when 'won'
      puts 'You have won!'
    when 'lost'
      puts "You have lost! The hidden word was #{@word}"
    else
      puts 'Error! This should not be reached'
    end
  end
end

# Player handles the player input
class Player
  attr_reader :guessed_letters

  def initialize(guessed_letters = [])
    @guessed_letters = guessed_letters
  end

  def player_guess
    valid_guess = false

    until valid_guess
      puts 'Your guess?'
      guess = gets.chomp.upcase
      if Rules.guess_is_valid?(guess, @guessed_letters)
        valid_guess = true
      else
        puts 'Incorrect input. Enter a single character from A to Z'
      end
    end

    guessed_letters << guess
    guess
  end
end

gm = GM.new
gm.new_game
