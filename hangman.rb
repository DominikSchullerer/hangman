# frozen_string_literal: true

require 'yaml'

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

  def self.input_is_valid?(input, guessed_letters)
    valid = true
    valid = false unless input.match?(/\A[A-Z]\z/)
    valid = false if guessed_letters.include?(input)
    valid = true if input == 'SAVE'
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
    puts "Hangman!\n\n"
    main_loop
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

    @player.guessed_letters << char

    @board.word_string = Rules.updated_word_string(@board.word, @board.correct_letters)
  end

  def game_loop
    gamestate = 'playing'

    @board.draw_board
    while gamestate == 'playing'
      input = @player.player_input

      if input == 'SAVE'
        save_game
        gamestate = 'saved'
      else
        handle_guess(input)
        @board.draw_board
        gamestate = Rules.gamestate(@board.word, @board.word_string, @board.wrong_letters)
      end
    end

    @board.put_final_message(gamestate)
  end

  def main_loop
    running = true
    while running
      puts 'What do you want to do?'
      puts "(n)ew game \n(q)uit \n(l)oad"
      case gets.downcase.chomp
      when 'n'
        new_game
      when 'q'
        running = false
      when 'l'
        load_game
      else
        puts "Invalid Input \n\n"
      end
    end
  end

  def save_game
    serialized_board = YAML.dump(@board)

    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')

    File.open('saved_games/save.yaml', 'w') do |file|
      file.puts serialized_board
    end
  end

  def load_game
    filename = 'saved_games/save.yaml'
    if File.exist?(filename)
      @player = Player.new

      @board = YAML.safe_load(
        File.read(filename),
        permitted_classes: [Board]
      )

      File.delete(filename)

      @board.correct_letters.each { |char| @player.guessed_letters << char }
      @board.wrong_letters.each { |char| @player.guessed_letters << char }

      game_loop
    else
      puts "\nNo savedata found\n\n"
    end
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
    puts @word_string
    print 'Correct letters: '
    @correct_letters.each { |char| print "#{char} " }
    puts ''
    print 'Incorrect letters: '
    @wrong_letters.each { |char| print "#{char} " }
    puts ''
  end

  def put_final_message(gamestate)
    case gamestate
    when 'won'
      puts "\nYou have won!\n\n"
    when 'lost'
      puts "\nYou have lost! The hidden word was #{@word}\n\n"
    when 'saved'
      puts "\nYou have saved your game.\n\n"
    end
  end
end

# Player handles the player input
class Player
  attr_accessor :guessed_letters

  def initialize(guessed_letters = [])
    @guessed_letters = guessed_letters
  end

  def player_input
    valid_input = false

    until valid_input
      puts 'Guess a letter of the hidden word or enter (save) to save and quit'
      input = gets.chomp.upcase
      if Rules.input_is_valid?(input, @guessed_letters)
        valid_input = true
      else
        puts 'Incorrect input. Enter a single character from A to Z or (save).'
      end
    end

    input
  end
end

GM.new
