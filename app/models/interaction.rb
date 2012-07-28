class Interaction
  attr_accessor :sentiment, :gender, :raw
  def initialize(hash)
    @raw = hash
    @sentiment = get_sentiment(hash)
    @gender = get_gender(hash)
  end

  def get_sentiment(hash)
    return nil unless hash["salience"]
    s = hash["salience"]["content"]["sentiment"].to_i
    if s>1
      "positive"
    elsif s<-1
      "negative"
    else
      "neutral"
    end
  end

  def get_gender(hash)
    if hash["demographic"]
      g = hash["demographic"]["gender"]
      if g =~ /female/
        "female"
      else
        "unisex"
      end
    else
      "unknown"
    end
  end
end
