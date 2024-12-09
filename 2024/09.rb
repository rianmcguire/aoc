#!/usr/bin/env ruby

FileRecord = Struct.new(:id, :length) do
  def to_s
    id.to_s * length
  end
end

SpaceRecord = Struct.new(:length) do
  def to_s
    "." * length
  end
end

disk = []

id = 0
space = false
ARGF.read.chomp.each_char do |c|
  c = c.to_i
  if space
    disk << SpaceRecord.new(c) if c > 0
  else
    disk << FileRecord.new(id, c)
    id += 1
  end

  space = !space
end

loop do
  # puts disk.map { |r| r.to_s }.join

  while disk.last.is_a?(SpaceRecord)
    disk.pop
  end

  space_index = disk.index { _1.is_a?(SpaceRecord) }
  break if space_index.nil?
  space = disk[space_index]

  f = disk.last
  f.length -= 1
  disk.delete(f) if f.length == 0

  disk.insert(space_index, FileRecord.new(f.id, 1))
  space_index += 1
  space.length -= 1
  disk.delete_at(space_index) if space.length == 0
end

result = 0
i = 0
disk.each do |r|
  r.length.times do
    result += i * r.id
    i += 1
  end
end

puts result
