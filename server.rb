require_relative 'db'
require_relative 'aoj_api'
require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'set'
require 'pp'
require 'uri'

def db
  @db ||= DB.new
end

def aoj
  @aoj ||= AOJ.new
end

def update(name)
  latest = db.latest_solved(name)
  date_begin = 0
  if latest
    date_begin = latest[:time].to_i * 1000 + 1000
  end
  res = aoj.solved_record(name, date_begin)
  l = res[:solved_record_list]
  if l.is_a?(Hash)
    entries = l[:solved].map{|s| [s[:date].to_i, s[:problem_id].to_i]}
    @db.add_solved(name, entries)
  end
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
  @user1 = request["user1"]
  @user2 = request["user2"]
  update(@user1)
  update(@user2)
  @s1 = Set[*db.solved_history(@user1, Time.now.to_i * 1000).map{|s| s[:id]}]
  @s2 = Set[*db.solved_history(@user2, Time.now.to_i * 1000).map{|s| s[:id]}]
  slim :show
end

def generate_diff_array(u1, h1, u2, h2)
  all = (h1 + h2).sort_by{|h| h[:time]}
  data = []
  diff = Set.new
  solved = Set.new
  all.each do |h|
    if h[:user_id] == u1
      solved << h[:id]
      if diff.include?(h[:id])
        diff.delete(h[:id])
        data << [h[:time].to_i * 1000, diff.size]
      end
    elsif h[:user_id] == u2
      unless solved.include?(h[:id])
        diff << h[:id]
        data << [h[:time].to_i * 1000, diff.size]
      end
    end
  end
  data
end

get '/diff' do
  u1 = request["user1"]
  u2 = request["user2"]
  h1 = db.solved_history(u1, Time.now.to_i * 1000)
  h2 = db.solved_history(u2, Time.now.to_i * 1000)
  data = []
  data << {user_id: u1, data: generate_diff_array(u1, h1, u2, h2)}
  data << {user_id: u2, data: generate_diff_array(u2, h2, u1, h1)}
  json data
end
