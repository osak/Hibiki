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
  ts = (h1 + h2).map(&:date).sort.uniq
  data = []
  h1_idx = 0
  h2_idx = 0
  ts.each do |t|
    while h1_idx < h1.size && h1[h1_idx].date <= t
      h1_idx += 1
    end
    h1_idx -= 1
    while h2_idx < h2.size && h2[h2_idx].date <= t
      h2_idx += 1
    end
    h2_idx -= 1
    data << [t.to_i * 1000, (h2[h2_idx].solved - h1[h1_idx].solved).size]
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
