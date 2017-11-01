git clone https://github.com/rbenv/rbenv.git ~/.rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.profile
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
rbenv install 2.4.0
rbenv global 2.4.0
gem install bundler
rbenv rehash
gem install pg -v '0.21.0'
gem install rails -v 5.1.4
cd /vagrant
gem install bundler --pre
bundle install
echo 'export SECRET_KEY_BASE=meh' >> ~/.profile
echo 'export RAILS_ENV=development' >> ~/.profile
echo 'export ES_HOST=10.0.2.2:9200' >> ~/.profile

export SECRET_KEY_BASE=meh
export RAILS_ENV=development
export ES_HOST=10.0.2.2:9200
