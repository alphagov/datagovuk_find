module PrivateBetaUser
  BLACKLIST = ENV.fetch('PRIVATE_BETA_USER_BLACKLIST', '').split(';')
  SALT = ENV.fetch("PRIVATE_BETA_USER_SALT", '')

  MEMORABLE_WORDS = {
    'a' => 'alpha',
    'b' => 'bravo',
    'c' => 'charlie',
    'd' => 'delta',
    'e' => 'echo',
    'f' => 'foxtrot',
    'g' => 'golf',
    'h' => 'hotel',
    'i' => 'india',
    'j' => 'juliet',
    'k' => 'kilo',
    'l' => 'lima',
    'm' => 'mike',
    'n' => 'november',
    'o' => 'oscar',
    'p' => 'papa',
    'q' => 'quebec',
    'r' => 'romeo',
    's' => 'sierra',
    't' => 'tango',
    'u' => 'uniform',
    'v' => 'victor',
    'w' => 'whiskey',
    'x' => 'xray',
    'y' => 'yankee',
    'z' => 'zulu',
    '0' => 'zero',
    '1' => 'one',
    '2' => 'two',
    '3' => 'three',
    '4' => 'four',
    '5' => 'five',
    '6' => 'six',
    '7' => 'seven',
    '8' => 'eight',
    '9' => 'nine',
    '-' => 'dash',
    '/' => 'dot'
  }

  def generate(username)
    s = Digest::SHA256
    hash = s.base64digest(SALT + username).downcase
    hash[0,8].split('').map { |c| MEMORABLE_WORDS[c] }.join(' ')
  end

  def authenticate?(username, password)
    (generate(username) == password) && !blacklisted?(username)
  end

  def blacklisted?(username)
    BLACKLIST.include?(username)
  end

  module_function :generate, :authenticate?, :blacklisted?
end
