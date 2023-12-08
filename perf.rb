#!/usr/bin/env ruby

require 'benchmark'
require 'open3'

files = Dir["*.rb"].sort.reject { File.identical? _1, __FILE__ }
max_length = files.map(&:length).max

files.each do |file|
  input = "#{File.basename(file, ".rb").gsub("b", "")}.txt"
  STDOUT.write file.ljust(max_length, " ")
  t = Benchmark.realtime do
    Open3.capture3("./#{file}", "#{input}")
  end
  puts " - #{t.round(3)}s"
end
