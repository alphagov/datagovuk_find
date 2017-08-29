word_file_path = Rails.root.join('config', 'wordlist.txt')
WORD_LIST = File.read(word_file_path).lines.map(&:chomp)
