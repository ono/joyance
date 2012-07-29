class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream

  class << self
    def total_by_sentiment(stream)
      Counter.where(stream: stream).
                    select("sentiment, sum(count) as total").
                    group("sentiment")
    end

    def recent_total(stream)
      recent_total = Counter.where(stream: stream).
                      where("created_at > ?", 3.minutes.ago).
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
          counter.count += 1
          counter.save!

          push counter, intr

          p "#{"%02d" % counter.hour}:#{"%02d" % counter.minute}-#{stream_name}-#{intr.sentiment}: #{counter.count}"
        end

      end
    end

    def push(counter, interaction)
      return unless pusher?

      if !@last_push || @last_push < 1.seconds.ago
        total = total_by_sentiment counter.stream
        recent = recent_total counter.stream

        Pusher[counter.stream].trigger!('recent', recent.to_json)
        Pusher[counter.stream].trigger!('total', total.to_json)
        Pusher[counter.stream].trigger!('tweet', interaction.to_json)
        @last_push = Time.now

      end
    end

    def pusher?
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
