#!/usr/bin/env ruby

lines = ARGF.each_line.map do |line|
  line.chomp
end

# Find the columns with the operations
ops_with_index = lines.last.chars.each_with_index.filter { |c, i| c != " " }

y_length = lines.length

result = ops_with_index.zip(ops_with_index.drop(1)).sum do |this, nxt|
  # The numbers range from the same column as the op
  op, start_i = this

  if nxt
    # Until the 2 characters before the next operation (inclusive)
    end_i = nxt[1] - 2
  else
    # Or the end of the line
    end_i = lines.last.length - 1
  end
  
  # Slice out the vertical numbers
  nums = (start_i..end_i).map do |x|
    (y_length - 1).times.map do |y|
      lines[y][x]
    end.join.to_i
  end

  nums.reduce(&op.to_sym)
end

puts result
