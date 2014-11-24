class SolvedStat
  attr_reader :user_id, :solved, :date

  def initialize(user_id, solved, date)
    @user_id = user_id.freeze
    @solved = solved.freeze
    @date = date.freeze
  end

  def daycmp(t1, t2)
    [t1.year, t1.month, t1.day] <=> [t2.year, t2.month, t2.day]
  end

  def <=>(ss)
    daycmp(date, ss.date)
  end
  include Comparable
end

