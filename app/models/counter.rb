require 'pp'

class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream

  class << self
    def monitor(stream)
      Counter.consume(stream) do |i|
        sentiment = sentiment(i)
        gender = gender(i)

        if sentiment
          counter = get_instance(stream,gender,sentiment)
          counter.count ||= 0
          counter.count += 1
          counter.save!
        end

        p "#{Time.now}:#{stream}:#{sentiment}:#{gender}"
      end
    end

    def sentiment(interaction)
      return nil unless interaction["salience"]
      s = interaction["salience"]["content"]["sentiment"].to_i
      if s>1
        "positive"
      elsif s<-1
        "negative"
      else
        "neutral"
      end
    end

    def gender(interaction)
      if interaction["demographic"]
        g = interaction["demographic"]["gender"]
        if g =~ /female/
          "female"
        else
          "unisex"
        end
      else
        "unknown"
      end
    end

    def get_instance(stream, gender, sentiment)
      now = Time.now.utc

      conditions = {
        :date => now.to_date,
        :hour => now.hour,
        :minute => now.min,
        :stream => stream,
        :gender => gender,
        :sentiment => sentiment
      }

      Counter.where(conditions).first || Counter.create(conditions)
    end

    def user_id
      ENV["DATASIFT_USERNAME"]
    end

    def api_key
      ENV["DATASIFT_KEY"]
    end

    def user
      @@user ||= DataSift::User.new(user_id.dup, api_key.dup)
    end

    def load_definition(name)
      filepath = "#{Rails.root}/app/definitions/#{name}.datasift"
      File.open(filepath, "rb").read
    end

    def consume(stream)
      definition = user.createDefinition(load_definition(stream))
      consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
      consumer.consume(true) do |interaction|
        yield(interaction) if interaction
      end
    end

  end

end
