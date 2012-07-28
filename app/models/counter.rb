class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream

  class << self
    def count_up(stream_name)
      s = Stream.new stream_name
      s.consume do |json|
        intr = Interaction.new(json)

        if intr.sentiment
          counter = get_instance(s.name, intr)
          counter.count ||= 0
          counter.count += 1
          counter.save!
        end

        p "#{Time.now}:#{stream_name}:#{intr.sentiment}:#{intr.gender}"
      end
    end

    def get_instance(stream, interaction)
      now = Time.now.utc

      conditions = {
        :date => now.to_date,
        :hour => now.hour,
        :minute => now.min,
        :stream => stream,
        :gender => interaction.gender,
        :sentiment => interaction.sentiment
      }

      Counter.where(conditions).first || Counter.create(conditions)
    end
  end
end
