#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require 'pp'

if ARGV.empty?
  abort "Usage: #{$0} [binding key]"
end

conn = Bunny.new(:automatically_recover => false)
conn.start

ch  = conn.create_channel
x   = ch.topic("topic_logs")
q   = ch.queue("", :exclusive => true)

isArray=0

ARGV.each do |severity|
  
  q.bind(x, :routing_key => severity)

  if severity.include? " "

  	isArray = 1

  	array = Array.new

  	array = severity.split(/ /)

  	array.size.times do |item|
  		puts array[item]
  	end

  end

end

puts "[*] Waiting for logs. To exit press CTRL+C"

begin

  i = 1
  
  ARGV.each do |severity|
  	
  q.subscribe(:block => true) do |delivery_info, properties, body|

	      if severity=="#" or severity==delivery_info.routing_key
	        	puts " [#{i}] - #{body}"
	      end

      	  i = i+1

  end
  
end

rescue Interrupt => _
  ch.close
  conn.close

  exit(0)
end