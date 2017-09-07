module PrivateBetaUser
  BLACKLIST = ENV.fetch('PRIVATE_BETA_USER_BLACKLIST', '').split(';')
  SALT = ENV.fetch("PRIVATE_BETA_USER_SALT", '')

  def generate(username)
    s = Digest::SHA256
    hash = s.hexdigest(SALT + username).to_i(16)
    words = []

    (1..3).each do
      words << WORD_LIST[hash % WORD_LIST.length]
      hash = hash / WORD_LIST.length
    end

    words.join(' ')
  end

  def authenticate?(username, password)
    (generate(username) == password) && !blacklisted?(username)
  end

  def blacklisted?(username)
    BLACKLIST.include?(username)
  end

  module_function :generate, :authenticate?, :blacklisted?
end
