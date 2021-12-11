def input filename
  File.read(filename).split(',').map &:to_i
end

ary    = input('input')
ring   = Array.new(9) {0}
head   = 0
result = 0

ary.each {|v|
  ring[v] += 1
  result  += 1
}

# days = 80
days = 256

days.times {
  # head always points to the current generation with 0-th counter
  newborn = ring[head]
  result += newborn

  # we simulate the day by moving the head one step to the right
  # we just need to increase the count of those which went to the next lap (those which come from counter 0 to counter 6).
  # Since they will be +6 from the next head position - they are +7 from the old head!
  ring[(head + 7) % 9] += newborn
  head = (head + 1) % 9

  # alternatively we could step to the next day first, and then the 6-th counter would be 3 steps behind us,
  # (this operation involves taking a modulo of a potentially negative number, which is defined differently in different languages.
  # the following works in Ruby and Python, but does not in C/C++, Go.
  # So going +7 is a somewhat more "portable" solution.)
  # head = (head + 1) % 9
  # ring[(head - 3) % 9] += newborn
}

puts result

