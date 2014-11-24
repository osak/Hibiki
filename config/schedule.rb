every 1.day, :at => '9:00 am' do
  command 'cd /var/www/Hibiki/current; /usr/local/bin/bundle exec ruby2.0 crawler.rb'
end
