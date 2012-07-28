require 'pp'

class Stream
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def consume
    definition = user.createDefinition(load_definition(@name))
    consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
    consumer.consume(true) do |interaction|
      yield(interaction) if interaction
    end
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
end
