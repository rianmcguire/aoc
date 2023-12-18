#!/usr/bin/env ruby

require 'benchmark'
require 'open3'

files = Dir["*.rb", "*.exe"].sort.reject { File.identical?(_1, __FILE__) || _1.include?("bench") }
max_length = files.map(&:length).max

files.each do |file|
  input = "#{file.split(".").first.gsub("b", "")}.txt"
  STDOUT.write file.ljust(max_length, " ")
  STDOUT.write " -"
  3.times do
    t = Benchmark.realtime do
      stdout, stderr, status = Open3.capture3("./#{file}", "#{input}")
      raise "Failed: #{stdout} #{stderr} #{status.inspect}" if status.exitstatus != 0
    end
    STDOUT.write " "
    STDOUT.write sprintf("%2.3fs", t)
  end
  puts
end
