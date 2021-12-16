# more or less straightforward "packet parsing"
# "bit" manipulation is done by converting "hex" string into a string of 0's and 1's
# which is not super efficient, but not prohibitevely so for the purposes of AoC.

def input filename
  File.readlines(filename).map {|x|
    x.chomp
  }
end

class BinView
  def initialize bin, range, label
    @bin, @range, @label = bin, range, label
  end

  def str
    @bin[@range]
  end

  def val
    str.to_i(2)
  end

  def inspect full = false
    if full
      "#{@label}: #{@bin} #{@range} #{str} #{val}"
    else
      "#{@label}: #{str} #{val}"
    end
  end
end

class Packet
  def initialize bin
    @bin  = bin
    @subs = []
    @len  = 0
  end

  def << x
    @subs << x
  end

  attr_reader :subs
  attr_accessor :v, :t, :len, :lit, :lit_value

  def sum_versions
    r = v
    subs.each {|s|
      r += s.sum_versions
    }
    r
  end

  def eval
    case t
    when 0
      sum = 0
      @subs.each {|x| sum += x.eval}
      sum
    when 1
      prod = 1
      @subs.each {|x| prod *= x.eval}
      prod
    when 2
      min = @subs[0].eval
      @subs[1..-1].each {|x|
        t = x.eval
        if min > t
          min = t
        end
      }
      min
    when 3
      max = @subs[0].eval
      @subs[1..-1].each {|x|
        t = x.eval
        if max < t
          max = t
        end
      }
      max
    when 4
      lit_value
    when 5
      if @subs[0].eval > @subs[1].eval
        1
      else
        0
      end
    when 6
      if @subs[0].eval < @subs[1].eval
        1
      else
        0
      end
    when 7
      if @subs[0].eval == @subs[1].eval
        1
      else
        0
      end
    end
  end
end

def parse_packet bin, verbose = false
  puts "Raw: #{bin} #{bin.size}" if verbose

  result = Packet.new(bin)

  bv = ->(range, label; x) {
    x = BinView.new(bin, range, label)
    p x if verbose

    result.len += range.count
    x
  }

  result.v = bv[0...3, "version"].val
  result.t = bv[3...6, "typeID"].val

  i = result.len

  if result.t == 4
    result.lit = ""
    while bin[i] == '1'
      result.lit += bv[i ... i+5, "litgroup_#{(i - 6) / 5 + 1}"].str[1..-1]
      i          += 5
    end
    result.lit += bv[i ... i+5, "litgroup_#{(i - 6) / 5 + 1}"].str[1..-1]
    result.lit_value = result.lit.to_i(2)

    # padding is not actually used anywhere? just a lowly prank from the author of the "puzzle"?
    # packet_end = (result.len + 3) & ~3
    # bv[result.len ... packet_end, "padding"]

    puts "literal: #{result.lit} #{result.lit_value} final len: #{result.len}" if verbose
  else
    if bv[6...7, "lenbit"].val == 0
      puts "two operator" if verbose

      sublen = bv[result.len ... result.len+15, "subpackets length"].val

      while sublen > 0
        packet = parse_packet(bin[result.len ... bin.size])
        result << packet

        result.len += packet.len
        sublen     -= packet.len
      end
    else
      num_sub_packets = bv[result.len ... result.len+11, "num_subpackets"].val

      num_sub_packets.times {|i|
        packet = parse_packet(bin[result.len ... bin.size])
        result << packet

        result.len += packet.len
      }
    end
  end

  result
end

def to_bin str
  width = str.length * 4
  "%0*b" % [width, str.to_i(16)]
end

def assert x, y
  raise "#{x} != #{y}" if x != y
end

if __FILE__ == $0
  assert parse_packet(to_bin('8A004A801A8002F478')).sum_versions, 16
  assert parse_packet(to_bin('620080001611562C8802118E34')).sum_versions, 12
  assert parse_packet(to_bin('C0015000016115A2E0802F182340')).sum_versions, 23
  assert parse_packet(to_bin('A0016C880162017C3686B18A3D4780')).sum_versions, 31

  # finds the sum of 1 and 2, resulting in the value 3.
  assert parse_packet(to_bin('C200B40A82')).eval, 3

  # finds the product of 6 and 9, resulting in the value 54.
  assert parse_packet(to_bin('04005AC33890')).eval, 54

  # finds the minimum of 7, 8, and 9, resulting in the value 7.
  assert parse_packet(to_bin('880086C3E88112')).eval, 7

  # finds the maximum of 7, 8, and 9, resulting in the value 9.
  assert parse_packet(to_bin('CE00C43D881120')).eval, 9

  # produces 1, because 5 is less than 15.
  assert parse_packet(to_bin('D8005AC2A8F0')).eval, 1

  # produces 0, because 5 is not greater than 15.
  assert parse_packet(to_bin('F600BC2D8F')).eval, 0

  # produces 0, because 5 is not equal to 15.
  assert parse_packet(to_bin('9C005AC2F8F0')).eval, 0

  # produces 1, because 1 + 3 = 2 * 2.
  assert parse_packet(to_bin('9C0141080250320F1802104A08')).eval, 1

  line   = input('input')[0]
  packet = parse_packet(to_bin(line))

  puts "Part1: #{packet.sum_versions}"
  puts "Part2: #{packet.eval}"
end
