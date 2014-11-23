require 'redis'
require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'set'
require 'pp'

class SolvedStat
  attr_reader :user_id, :solved, :date

  def initialize(user_id, solved, date)
    @user_id = user_id.freeze
    @solved = solved.freeze
    @date = date.freeze
  end

  def daycmp(t1, t2)
    if t1.year != t2.year
      t1.year <=> t2.year
    elsif t1.month != t2.month
      t1.month <=> t2.month
    else
      t1.day <=> t2.day
    end
  end

  def <=>(ss)
    daycmp(date, ss.date)
  end
  include Comparable
end

def redis
  @redis ||= Redis.new
end

def get_solved(key)
  name, utc = key.match(/(.*):(\d+)/).captures
  s = Set[*redis.smembers(key).map(&:to_i)]
  SolvedStat.new(name, s, Time.at(utc.to_i))
end

def recent_solved(name)
  dict = "dict:#{name}"
  key = redis.zrange(dict, -1, -1).first
  get_solved(key)
end

def solved_history(name)
  dict = "dict:#{name}"
  key = redis.zrange(dict, 0, -1)
  key.map do |k|
    get_solved(k)
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
  @s1 = recent_solved("osa_k")
  @s2 = recent_solved("Mi_Sawa")
  slim :show
end

def generate_diff_array(h1, h2)
  data = []
  h2_idx = 0
  h1.each do |s1|
    while h2_idx < h2.size && h2[h2_idx] < s1
      h2_idx += 1
    end
    break if h2_idx >= h2.size
    s2 = h2[h2_idx]
    date = Time.new(s1.date.year, s1.date.month, s1.date.day)
    data << [date.to_i * 1000, (s2.solved - s1.solved).size]
  end
  data
end

get '/diff' do
  u1 = "osa_k"
  u2 = "Mi_Sawa"
  h1 = solved_history(u1)
  h2 = solved_history(u2)
  data = []
  data << {user_id: u1, data: generate_diff_array(h1, h2)}
  data << {user_id: u2, data: generate_diff_array(h2, h1)}
  json data
end
