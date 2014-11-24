class DB
  def initialize
    @redis = Redis.new
  end

  def add_solved(name, ids, time)
    key = "#{name}:#{timestamp(time)}"
    @redis.sadd(key, ids)
    @redis.zadd(dictname(name), numerical_timestamp(time), key)
  end

  private
  def timestamp(t = Time.now)
    t.strftime("%Y-%m-%d")
  end

  def numerical_timestamp(t = Time.now)
    t.strftime("%Y%m%d").to_i
  end
end
