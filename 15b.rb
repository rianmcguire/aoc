#!/usr/bin/env ruby

def hash_alg(string)
    value = 0
    string.chars.each do |c|
        value += c.ord
        value *= 17
        value = value % 256
    end
    value
end

Lens = Struct.new(:label, :focal)

boxes = Hash.new { |h,k| h[k] = [] }
ARGF.read.chomp.split(",").each do |step|
    label, focal = *step.split(/[\-=]/)
    box_index = hash_alg(label)

    if !focal
        # Remove
        boxes[box_index].delete_if { _1.label == label } 
    else
        lens = Lens.new(label, focal.to_i)
        # Add
        if i = boxes[box_index].index { _1.label == lens.label }
            # Replace existing with same label
            boxes[box_index][i] = lens
        else
            # Add to end
            boxes[box_index] << lens
        end
    end
end

boxes.sum do |box_index, box|
    box.each_with_index.sum do |lens, i|
        (box_index + 1) * (i + 1) * lens.focal
    end
end.then { puts _1 }
