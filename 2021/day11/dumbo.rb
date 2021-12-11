class Board
  def initialize lines
    @width = lines[0].size
    @height = lines.size

    @board = Array.new(size) {0}
    fill lines

    @total_flashes = 0
    @num_steps     = 0
  end

  def size
    width * height
  end

  def [] *args
    raise "Incorrect indexing: #{args.inspect}" if args.size < 1 || args.size > 2
    index = if args.size == 1
              args[0]
            else
              args[1] * width + args[0]
            end
    @board[index]
  end

  def []= *args
    raise "Incorrect indexing: #{args.inspect}" if args.size < 2 || args.size > 3
    if args.size == 2
      index = args[0]
      return if index < 0 || index > size - 1

      value = args[1]
    else
      x = args[0]
      y = args[1]

      return if x < 0 || x > width-1
      return if y < 0 || y > height-1

      index = y * width + x
      value = args[2]
    end

    @board[index] = value
  end

  def fill lines
    lines.each_with_index {|l, y|
      x = 0
      l.chars.each {|c|
        self[x, y] = c.to_i
        x += 1
      }
    }
  end

  def print
    height.times {|y|
      width.times {|x|
        Kernel.print self[x, y]
      }
      puts
    }
  end

  def inc index, flashed, flash_queue
    if Array === index
      x, y = *index
      return if x < 0 || x > width-1
      return if y < 0 || y > height-1

      index = y * width + x
    end

    return if flashed[index]

    self[index] += 1

    if self[index] > 9
      self[index] = 0

      if !flashed[index]
        @total_flashes += 1
        flashed[index] = true
        flash_queue << index
      end
    end
  end

  def step
    flashed = Array.new(size) {false}
    flash_queue = []

    size.times {|index|
      inc(index, flashed, flash_queue)
    }

    while flash_queue.size > 0
      flash_index = flash_queue.shift
      y, x = flash_index.divmod(width)

      inc([x - 1, y - 1], flashed, flash_queue)
      inc([    x, y - 1], flashed, flash_queue)
      inc([x + 1, y - 1], flashed, flash_queue)
      inc([x - 1, y    ], flashed, flash_queue)
      inc([x + 1, y    ], flashed, flash_queue)
      inc([x - 1, y + 1], flashed, flash_queue)
      inc([x,     y + 1], flashed, flash_queue)
      inc([x + 1, y + 1], flashed, flash_queue)
    end

    @num_steps += 1
  end

  def all_flash?
    board.all? {|x| x == 0}
  end

  attr_reader :width, :height, :board, :total_flashes, :num_steps
end

# lines = File.readlines('sample_1').map {|x| x.chomp}
# lines = File.readlines('sample_input').map {|x| x.chomp}
lines = File.readlines('input').map {|x| x.chomp}
board = Board.new(lines)

puts "Before:"
board.print

loop {
  board.step

  puts "step #{board.num_steps}:"
  board.print

  if board.all_flash?
    puts "All flash at step #{board.num_steps}"
    break
  end
}
puts board.total_flashes
