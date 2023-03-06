# frozen_string_literal: true

File.open('resources/word_list.txt', 'w') do |word_list|
  File.readlines('resources/word_list_orig.txt').each do |line|
    word_list.puts line.chomp if line.chomp.length > 4 && line.length < 13
  end
end
