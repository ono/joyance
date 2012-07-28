class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream

  def user_id
    ENV["DATASIFT_USERNAME"]
  end

  def api_key
    ENV["DATASIFT_KEY"]
  end
end
