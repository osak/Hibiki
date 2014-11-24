require_relative 'aoj_api'
require_relative 'db'
require 'pp'

class Crawler
  def initialize
    @db = DB.new
    @aoj = AOJ.new
  end

  def crawl_user(name)
    solved = @aoj.solved_record(name)
    solved_ids = solved[:solved_record_list][:solved].map{|s| s[:problem_id].to_i}
    @db.add_solved(name, solved_ids, Time.now)
  end

  def crawl
    crawl_user("osa_k")
    crawl_user("Mi_Sawa")
  end
end

crawler = Crawler.new
crawler.crawl
