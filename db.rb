require_relative 'solved_stat'
require 'set'
require 'redis'

class DB
  def initialize
    @redis = Redis.new
  end

  def add_solved(name, entries)
    key = name
    @redis.zadd(name, entries.flatten)
  end

  def solved_history(name, t)
    res = @redis.zrangebyscore(name, 0, t, with_scores: true)
    res.map{|a,b| {user_id: name, id: a.to_i, time: Time.at(b.to_i)}}
  end

  private
  def timestamp(t = Time.now)
    t.strftime("%Y-%m-%d")
  end

  def numerical_timestamp(t = Time.now)
    t.strftime("%Y%m%d").to_i
  end

  def dictname(name)
    "dict:#{name}"
  end

  def solved_stat(name, key)
    y, m, d = key.match(/(\d{4})-(\d{2})-(\d{2})/).captures.map(&:to_i)
    s = Set[*@redis.smembers(key).map(&:to_i)]
    t = Time.new(y, m, d)
    SolvedStat.new(name, s, t)
  end
end
