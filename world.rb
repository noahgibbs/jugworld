#!/usr/bin/env ruby

require "redis"
require "multi_json"

JUG_CHANNELS = [
  "juggernaut:subscribe",
  "juggernaut:unsubscribe",
  "juggernaut:custom",
  "juggernaut"
]

def redis_object(options = {})
  @redis_obj ||= Redis.new(options)
end

def jug_publish(channels, data)
  message =  MultiJson.dump({ :channels => channels, :data => data })
  redis_object.publish("juggernaut", message)
end

#Juggernaut.publish("channel1", "Some data")
#Redis.new.publish("juggernaut", { "channels" => [ "channel1"], "data" => "Some data"})
#Juggernaut.publish("channel1", {:some => "data"})
#Juggernaut.publish(["channel1", "channel2"], ["foo", "bar"])

# Blocking call
redis_object.subscribe(JUG_CHANNELS) do |on|

  on.message do |type, msg|
    if type == "juggernaut"
      STDERR.puts "Jug message: #{msg.inspect}"
    elsif type["juggernaut:"]
      event_type = type.sub("juggernaut:", "")
      STDERR.puts "Jug event #{event_type}: #{msg.inspect}"
    else
      STDERR.puts "ERROR: unrecognized message type #{type.inspect}!"
    end
  end
end
