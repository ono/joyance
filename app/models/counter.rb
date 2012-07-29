class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream

  class << self
    def total_by_sentiment(stream)
      Counter.where(stream: stream).
                    select("sentiment, sum(count) as total").
                    group("sentiment")
    end

    def count_up(stream_name)
      s = Stream.new stream_name
      s.consume do |json|
        intr = Interaction.new(json)

        if intr.sentiment
          counter = get_instance(s.name, intr)
          counter.count ||= 0
          counter.count += 10
          counter.save!

          push counter

          p "#{"%02d" % counter.hour}:#{"%02d" % counter.minute}-#{stream_name}-#{intr.sentiment}: #{counter.count}"
        end

      end
    end

    def push(counter)
      return unless pusher?

      total = total_by_sentiment counter.stream
      Pusher[counter.stream].trigger!('total', total.to_json)
    end

    def pusher?
      p Pusher.app_id
      if ENV["DISABLE_PUSHER"] || !Pusher.app_id
        false
      else
        true
      end
    end

    def get_instance(stream, interaction)
      now = Time.now.utc

      conditions = {
        :date => now.to_date,
        :hour => now.hour,
        :minute => now.min,
        :stream => stream,
        :gender => "n/a", # gender information is useless
        :sentiment => interaction.sentiment
      }

      Counter.where(conditions).first || Counter.create(conditions)
    end
  end
end
