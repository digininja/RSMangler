#!/usr/bin/env ruby
#encoding: UTF-8

# == RSMangler: Take a wordlist and mangle it
#
# RSMangler will take a wordlist and perform various manipulations on it similar to
# those done by John the Ripper with a few extras, the main one being permutations mode
# which takes each word in the list and combines it with the others to produce all
# possible permutations (not combinations, order matters).
#
# See the README for full information
#
# Original Author:: Robin Wood (robin@digininja.org)
# Version:: 1.4
# Copyright:: Copyright(c) 2012-2013, RandomStorm Limited - www.randomstorm.com
# Licence:: Creative Commons Attribution-Share Alike 2.0
#
# Changes:
# 1.4 - Added full leetspeak option, thanks Felipe Molina (@felmoltor)
#

require 'date'
require 'getoptlong'

# The left hand character is what you are looking for
# and the right hand one is the one you are replacing it
# with

leet_swap = {
  's' => '$',
  's' => 'z',
  'e' => '3',
  'a' => '4',
  'a' => '@',
  'o' => '0',
  'i' => '1',
  'i' => '!',
  'l' => '1',
  't' => '7',
  'b' => '8',
  'z' => '2',
}

# Common words to append and prepend if --common is allowed

common_words = [
  'pw',
  'pwd',
  'admin',
  'sys',
  '123456',
  '12345678',
  '1234',
  '123',
  'jesus',
  'passwsord',
  'love',
  'princess',
  'blessed',
  'sunshine',
  'faith',
  'phpbb',
  'qwerty',
  'letmein',
  'abc',
  'iloveyou',
  'test'
]

opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--file', '-f', GetoptLong::REQUIRED_ARGUMENT],
  ['--min', '-m', GetoptLong::REQUIRED_ARGUMENT],
  ['--max', '-x', GetoptLong::REQUIRED_ARGUMENT],
  ['--perms', '-p', GetoptLong::NO_ARGUMENT],
  ['--double', '-d', GetoptLong::NO_ARGUMENT],
  ['--reverse', '-r', GetoptLong::NO_ARGUMENT],
  ['--leet', '-t', GetoptLong::NO_ARGUMENT],
  ['--full-leet', '-T', GetoptLong::NO_ARGUMENT],
  ['--capital', '-c', GetoptLong::NO_ARGUMENT],
  ['--upper', '-u', GetoptLong::NO_ARGUMENT],
  ['--lower', '-l', GetoptLong::NO_ARGUMENT],
  ['--swap', '-s', GetoptLong::NO_ARGUMENT],
  ['--ed', '-e', GetoptLong::NO_ARGUMENT],
  ['--ing', '-i', GetoptLong::NO_ARGUMENT],
  ['--punctuation', GetoptLong::NO_ARGUMENT],
  ['--years', '-y', GetoptLong::NO_ARGUMENT],
  ['--acronym', '-a', GetoptLong::NO_ARGUMENT],
  ['--common', '-C', GetoptLong::NO_ARGUMENT],
  ['--pnb', GetoptLong::NO_ARGUMENT],
  ['--pna', GetoptLong::NO_ARGUMENT],
  ['--nb', GetoptLong::NO_ARGUMENT],
  ['--na', GetoptLong::NO_ARGUMENT],
  ['--force', GetoptLong::NO_ARGUMENT],
  ['--space', GetoptLong::NO_ARGUMENT],
  ['-v', GetoptLong::NO_ARGUMENT],
  ['--prep-words', GetoptLong::NO_ARGUMENT]
)

def good_call
  puts
  puts 'Good call, either reduce the size of your word list or use the --perms option to disable permutations'
  puts
  exit
end

# Display the usage
def usage
  puts 'rsmangler v 1.4 Robin Wood (robin@digininja.org) <www.randomstorm.com>

  To pass the initial words in on standard in do:

    cat wordlist.txt | ./rsmangler.rb --file - > new_wordlist.rb

    All options are off by default except --perms, these parameters turn them on

    Usage: rsmangler.rb [OPTION]
    --help, -h: show help
    --file, -f: the input file, use - for STDIN
    --max, -x: maximum word length
    --min, -m: minimum word length
    --perms, -p: permutate all the words
    --double, -d: double each word
    --reverse, -r: reverser the word
    --leet, -t: l33t speak the word
    --full-leet, -T: all posibilities l33t
    --capital, -c: capitalise the word
    --upper, -u: uppercase the word
    --lower, -l: lowercase the word
    --swap, -s: swap the case of the word
    --ed, -e: add ed to the end of the word
    --ing, -i: add ing to the end of the word
    --punctuation: add common punctuation to the end of the word
    --years, -y: add all years from 1990 to current year to start and end
    --acronym, -a: create an acronym based on all the words entered in order and add to word list
    --common, -C: add the following words to start and end: admin, sys, pw, pwd
    --pna: add 01 - 09 to the end of the word
    --pnb: add 01 - 09 to the beginning of the word
    --na: add 1 - 123 to the end of the word
    --nb: add 1 - 123 to the beginning of the word
    --force - don\'t check ooutput size
    --space - add spaces between words
    --prep-words - run all the additional commands on the entire generated wordlist before running permutations

    It might be a good idea to pipe everything through uniq (./rsmangler.rb | uniq) as there are probably going to be a few doubles (though not a lot)

    '

  exit
end

def binaryincrement(binarray)
  index = binarray.size - 1
  incremented = false
  while !incremented && index >= 0
    if binarray[index] == 0
      binarray[index] = 1
      incremented = true
      break
    else
      binarray[index] = 0
    end
    index -= 1
  end
  return binarray
end

def leet_variations(word, swap_array)
  count = 0
  swap_array.keys.each do |key|
  count += word.count(key)
end

variation     = Array.new(count, 0)
leetletterpos = Array.new(count, 0)
variationarr  = []
# Save the indexes where the leet letters can be substituted
pos           = 0
iter          = 0
tmpword       = word.dup

swap_array.each do |char, replace|
  pos = 0
  while !(pos = tmpword.index(char)).nil?
    leetletterpos[iter] = pos
    tmpword[pos] = '$'
    iter += 1
  end
end
# Create all posible combinations of subtitutions
src_chars = swap_array.keys.join
dst_chars = swap_array.values.join

begin
  tmpword = word.dup
  variation = binaryincrement(variation)
  idx = 0
  variation.each do |changeletter|
    if changeletter == 1
      # Tried tr! but it won't replace inline, probably because it doesn't know where the slice is happening
      tmpword[leetletterpos[idx], 1] = tmpword[leetletterpos[idx], 1].tr(src_chars, dst_chars)
    end
    idx += 1
  end
  variationarr << tmpword
end while variation != Array.new(count, 1)
  return variationarr
end

verbose     = false
leet        = false
full_leet   = false
perms       = true
double      = false
reverse     = false
capital     = false
upper       = false
lower       = false
swap        = false
ed          = false
ing         = false
punctuation = false
years       = false
acronym     = false
common      = false
pna         = false
pnb         = false
na          = false
nb          = false
force       = false
space       = false
file_handle = nil
min_length  = nil
max_length  = nil
prep_words  = false

begin
  opts.each do |opt, arg|
    case opt
    when '--help'
      usage
    when '--file'
      if arg == '-'
        file_handle = STDIN
      else
        if File.exist? arg
          file_handle = File.new(arg, 'r')
        else
          puts 'The specified file does not exist'
          exit
        end
      end
    when '--max'
      max_length = arg.to_i
    when '--min'
      min_length = arg.to_i
    when '--leet'
      leet = true
    when '--full-leet'
      full_leet = true
    when '--perms'
      perms = false
    when '--double'
      double = true
    when '--reverse'
      reverse = true
    when '--capital'
      capital = true
    when '--upper'
      upper = true
    when '--lower'
      lower = true
    when '--swap'
      swap = true
    when '--ed'
      ed = true
    when '--ing'
      ing = true
    when '--common'
      common = true
    when '--acronym'
      acronym = true
    when '--years'
      years = true
    when '--punctuation'
      punctuation = true
    when '--pna'
      pna = true
    when '--pnb'
      pnb = true
    when '--na'
      na = true
    when '--nb'
      nb = true
    when '--space'
      space = true
    when '--force'
      force = true
    when '-v'
      verbose = true
    when '--prep-words'
      prep_words = true
    end
  end
rescue => e
  puts e
  usage
end

if file_handle.nil?
  puts 'No input file specified'
  puts
  usage
  exit
end

file_words = []
while (x = file_handle.gets)
  x.chomp!
  file_words << x
end

file_handle.close

if !force && perms && file_words.length > 5
  puts '5 words in a start list creates a dictionary of nearly 100,000 words.'
  puts 'You have ' + file_words.length.to_s + ' words in your list, are you sure you wish to continue?'
  puts 'That is over ' + file_words.length.to_s  + ' to the power of ' + file_words.length.to_s + ' combinations. Be prepared to wait.'
  puts 'Hit ctrl-c to abort'
  puts

  interrupted = false
  trap('INT') { interrupted = true }

  5.downto(1) do |i|
    print i.to_s + ' '
    STDOUT.flush
    sleep 1

    good_call if interrupted
  end

  good_call if interrupted
end

wordlist = []

if !prep_words
  if perms
    for i in (1..file_words.length)
      file_words.permutation(i) { |c| wordlist << c.join }
      #file_words.permutation(i) { |c| puts c.join }
    end
  else
    wordlist = file_words
  end
else
  wordlist = file_words
end

acro = nil

if acronym
  acro = ''
  file_words.each { |c| acro += c[0, 1] }
  wordlist << acro
end

results = []
result = ""

xcommon = false
wordlist.each do |x|
  results << x

  results << x + x if double
  results << x.reverse if reverse
  results << x.capitalize if capital
  results << x.downcase if lower
  results << x.upcase if upper
  results << x.swapcase if swap
  results << x + 'ed' if ed
  results << x + 'ing' if ing

  if common
    common_words.each do |word|
      results << word + x
      results << x + word
    end
  end

  if full_leet
    leetarr = leet_variations(x, leet_swap)
    leetarr.each do |leetvar|
      results << leetvar
    end
  else
    # Only look at doing this if full leet is not enabled

    # Have to clone it otherwise the assignment is done
    # by reference and the gsub! updates both x and all_swapped
    all_swapped = x.clone
    if leet
      leet_swap.each_pair do |find, rep|
        all_swapped.gsub!(/#{find}/, rep)
        results << x.gsub(/#{find}/, rep)
      end
      results << all_swapped
    end
  end

  if punctuation
    for i in ('!@$%^&*()'.scan(/./))
      results << x + i.to_s
    end
  end

  if years
    for i in (1990..2020)
      results << i.to_s + x
      results << x + i.to_s
    end
  end

  if pna || pnb
    for i in (1..9)
      results << '0' + i.to_s + x if pnb
      results << x + '0' + i.to_s if pna
    end
  end

  if na || nb
    for i in (1..123)
      results << i.to_s + x if nb
      results << x + i.to_s if na
    end
  end
end

results.uniq!



if prep_words
  if perms
    for i in (1..results.length)
      results.permutation(i) { |c| newc = c.join
        if !max_length.nil? || !min_length.nil?
            if !max_length.nil? && !min_length.nil?
              res = newc.length < min_length || newc.length > max_length
            elsif !min_length.nil?
              res = newc.length < min_length
            elsif !max_length.nil?
              res = newc.length > max_length
            end
            if !res
              puts newc
            end
          else
            puts newc
          end

      }
    end

end
else
  results.each do |c|
    puts c
  end
end

if !max_length.nil? || !min_length.nil?
  results.delete_if do |x|
    res = false
    if !max_length.nil? && !min_length.nil?
      res = x.length < min_length || x.length > max_length
    elsif !min_length.nil?
      res = x.length < min_length
    elsif !max_length.nil?
      res = x.length > max_length
    end
    res
  end
end

exit
