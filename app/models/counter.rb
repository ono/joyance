require 'pp'

class Counter < ActiveRecord::Base
  attr_accessible :count, :date, :gender, :hour, :minute, :sentiment, :stream

  def moniter(definition_name)
    Counter.consume(definition_name) do |interaction|
      pp interaction
    end
  end

  class << self
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

    def consume(definition_name)
      definition = user.createDefinition(load_definition(definition_name))
      consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
      consumer.consume(true) do |interaction|
        yield(interaction) if interaction
      end
    end

  end

end
