class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream
end
