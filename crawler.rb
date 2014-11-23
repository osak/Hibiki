require_relative 'aoj_api'
require 'pp'
require 'redis'

class Crawler
  def initialize
    @redis = Redis.new
    @aoj = AOJ.new
  end

  def dict_for(name)
    "dict:#{name}"
  end

  def crawl_user(name)
    solved = @aoj.solved_record(name)
    solved_ids = solved[:solved_record_list][:solved].map{|s| s[:problem_id].to_i}
    cur_time = Time.now.to_i
    key = "#{name}:#{cur_time}"
    @redis.sadd(key, solved_ids)
    @redis.zadd(dict_for(name), cur_time, key)
  end

  def crawl
    crawl_user("osa_k")
    crawl_user("Mi_Sawa")
  end
end

crawler = Crawler.new
crawler.crawl
