def input filename
  File.read(filename).split(',').map &:to_i
end

# fully recursive version:
# - find the number of times the fish will spawn in the given days and its initial counter
# - for each spawn recurse to get the count of fishes which the child (and its descendants) will produce
# - memoize the results to thwart off the recursion depth
def fish_count days, counter
  memo_key = [days, counter]
  return MEMO[memo_key] if MEMO[memo_key]

  # count yourself
  result = 1
  return result if days <= counter

  days -= counter
  loop {
    # count the number of descendants
    result += fish_count(days - 1, 8)

    # go to the next spawn
    days -= 7
    break if days <= 0
  }

  MEMO[memo_key] = result
end

MEMO = {}
count = 0
input('input').each {|x| count += fish_count(256, x)}

puts count



