#!/usr/bin/env ruby

require 'benchmark'
require 'open3'

prefix_filter = ARGV[0]

def label(file)
  file.gsub(".exe", "")
end

files = Dir["*.rb", "*.py", "*.exe"].sort.reject { File.identical?(_1, __FILE__) || _1.include?("bench") }.filter { prefix_filter.nil? || _1.start_with?(prefix_filter) }
max_length = files.map { label(_1).length }.max

files.each do |file|
  input = "#{file.split(".").first.gsub("b", "")}.txt"
  STDOUT.write label(file).ljust(max_length, " ")
  STDOUT.write " "
    t, max_rss = 3.times.map do
    stdout, stderr, status = Open3.capture3("/usr/bin/time", "-l", "./#{file}", "#{input}")
    raise "Failed: #{stdout} #{stderr} #{status.inspect}" if status.exitstatus != 0
    t = stderr.match(/([\d.]+) real/)[1].to_f
    max_rss = stderr.match(/(\d+).*maximum resident set size/)[1].to_f
    STDOUT.write "-"

    [t, max_rss]
  end.min_by { |t, max_rss| t }
  max_rss_mb = max_rss / 1024 / 1024
  STDOUT.puts sprintf(" %6.3fs %5.1fMB", t, max_rss_mb)
end
