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
files = []

id = 0
space = false
ARGF.read.chomp.each_char do |c|
  c = c.to_i
  if space
    disk << SpaceRecord.new(c) if c > 0
  else
    file = FileRecord.new(id, c)
    disk << file
    files << file
    id += 1
  end

  space = !space
end

files.reverse.each do |file|
  file_index = disk.index(file)
  space_index = disk.index { _1.is_a?(SpaceRecord) && _1.length >= file.length }
  next if !space_index || space_index > file_index

  space = disk[space_index]
  disk[file_index] = SpaceRecord.new(file.length)
  disk.insert(space_index, file)
  space_index += 1
  space.length -= file.length
  disk.delete_at(space_index) if space.length == 0

  # puts disk.map { |r| r.to_s }.join
end

result = 0
i = 0
disk.each do |r|
  r.length.times do
    result += i * r.id if r.is_a?(FileRecord)
    i += 1
  end
end

puts result
