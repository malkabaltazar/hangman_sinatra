require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
  set :session_secret, "secret"
end

def new_game
  $line1 = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"]
  $line2 = ["N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
  $word = File.read('5desk.txt').lines.select {|l| (5..12).cover?(l.strip.size)}.sample.strip.upcase.chars
  $display = []
  $word.length.times do; $display.push("_"); end
  $man_hung = 0
  $man = []
  $message = ""
end

new_game

get '/' do
  if params["new"] == "true" then new_game else guess(params["letter"]) end
  erb :index, :locals => {:line1 => $line1.join(" "), :line2 => $line2.join(" "),
  :man => $man, :display => $display.join(" "), :message => $message}
end

def guess(letter)
  letter = letter.upcase
  slash(letter)
  if $word.include? letter
    display_word(letter)
  else
    loser(letter)
  end
end

def display_word(letter = nil)
  $word.each_with_index do |val, index|
    $display[index] = letter if val == letter
  end
  if $display.include? "_" == false
    $message = "#{$word.join}\nCongratulations, you win!"
  end
end

def slash(letter)
  if $line1.include? letter
    location = $line1.index(letter)
    $line1[location] = "/"
  elsif $line2.include? letter
    location = $line2.index(letter)
    $line2[location] = "/"
  else
    $message = "You have already guessed '#{letter}' or it is invalid input."
    $man_hung -= 1 unless $display.include? letter
  end
end

def loser(letter)
  $man_hung += 1
  case $man_hung
  when 0
    return
  when 1
    $man[0] = " o "
  when 2
    $man[1] = " | "
  when 3
    $man[1] = "/| "
  when 4
    $man[1] = "/|\\"
  when 5
    $man[2] = "/  "
  when 6
    $man[2] = "/ \\"
  when 7
    $message = "You lose. Word was: #{$word.join}."
  end
end
