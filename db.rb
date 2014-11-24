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
    res.map{|a,b| {user_id: name, id: a.to_i, time: Time.at(b.to_i / 1000)}}
  end

  def latest_solved(name)
    res = @redis.zrange(name, -1, -1, with_scores: true)
    if res.size > 0
      res = res.first
      {user_id: name, id: res[0].to_i, time: Time.at(res[1].to_i / 1000)}
    else
      nil
    end
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
