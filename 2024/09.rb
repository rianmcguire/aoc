#!/usr/bin/env ruby

RubyVM::YJIT.enable

Record = Struct.new(:id, :length) do
  def file?
    id
  end

  def space?
    !id
  end
end

disk = []

id = 0
space = false
ARGF.read.chomp.each_char do |c|
  c = c.to_i
  if space
    disk << Record.new(nil, c) if c > 0
  else
    disk << Record.new(id, c)
    id += 1
  end

  space = !space
end

file_index = space_index = nil
loop do
  # Prune any trailing space so we don't have to search through it
  while disk.last.space?
    disk.pop
  end

  # Find the last file
  file_index ||= disk.rindex { _1.file? }

  # Find the first free space
  space_index ||= disk.index { _1.space? }

  break if space_index > file_index

  space = disk[space_index]
  file = disk[file_index]

  # Move one block of the file into the space
  file.length -= 1
  disk.insert(space_index, Record.new(file.id, 1))
  space.length -= 1

  # We've inserted - adjust the indexes
  space_index += 1
  file_index += 1

  if file.length == 0
    disk.delete_at(file_index)
    file_index = nil
  end

  if space.length == 0
    disk.delete_at(space_index)
    space_index = nil
    file_index -= 1 if file_index
  end
end

result = 0
i = 0
disk.each do |r|
  r.length.times do
    result += i * r.id if r.file?
    i += 1
  end
end

puts result
