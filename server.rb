require_relative 'db'
require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'set'
require 'pp'

def db
  @db ||= DB.new
end

Process.daemon
File.open(File.expand_path("~/hibiki.pid"), "w") do |f|
  f.puts(Process.pid)
end

Dir.chdir(__dir__)
set :views, "templates"
set :static, true
set :public_folder, "static"

get '/show' do
  @s1 = db.recent_solved("osa_k")
  @s2 = db.recent_solved("Mi_Sawa")
  slim :show
end

def generate_diff_array(h1, h2)
  data = []
  h2_idx = 0
  h1.each do |s1|
    while h2_idx < h2.size && h2[h2_idx] <= s1
      h2_idx += 1
    end
    h2_idx -= 1
    s2 = h2[h2_idx]
    date = Time.new(s1.date.year, s1.date.month, s1.date.day)
    data << [date.to_i * 1000, (s2.solved - s1.solved).size]
  end
  data
end

get '/diff' do
  u1 = "osa_k"
  u2 = "Mi_Sawa"
  h1 = db.solved_history(u1)
  h2 = db.solved_history(u2)
  data = []
  data << {user_id: u1, data: generate_diff_array(h1, h2)}
  data << {user_id: u2, data: generate_diff_array(h2, h1)}
  json data
end
