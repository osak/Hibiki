every 1.day, :at => '9:00 am' do
  command 'cd /var/www/Hibiki/current; bundle exec ruby2.0 /var/www/Hibiki/current/crawler.rb'
end
