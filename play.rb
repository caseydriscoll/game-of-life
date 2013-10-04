#!/usr/bin/env ruby

require 'colorize'

@wrap = false
@debug = false

@pause = 0.01
@size = 20
@cycles = 1000

@start = 100

@live = "O".blue
@dead = "x".red

# The world is dead at instantiation
@world = Array.new(@size) { Array.new(@size) {@dead} }

@oldWorld = Array.new
@world.each { |r| @oldWorld.push(r.dup) }

@deadWorld = Array.new
@world.each { |r| @deadWorld.push(r.dup) }

@currentPlay = Time.now.getutc.strftime('%Y%m%d%H%M%S')
system "mkdir -p plays/#{@currentPlay}"

def flipCell(col, row)
  puts "flip cell #{col}, #{row}" if @debug
  if @world[col][row] == @live
    @world[col][row] = @dead
  else
    @world[col][row] = @live
  end
end

def rules(col, row)
  cell = @world[col][row]
  liveNeighbors = 0

  #if( @wrap || ( col == 0 && row == 0 ) )
  liveNeighbors += 1 if @world[col-1][row-1] == @live 
  liveNeighbors += 1 if @world[col-1][row] == @live
  liveNeighbors += 1 if @world[col-1][row+1] == @live
  liveNeighbors += 1 if @world[col][row-1] == @live
  liveNeighbors += 1 if @world[col][row+1] == @live
  liveNeighbors += 1 if @world[(col+1) % @size][row-1] == @live
  liveNeighbors += 1 if @world[(col+1) % @size][row] == @live
  liveNeighbors += 1 if @world[(col+1) % @size][row+1] == @live

  print "check cell #{col}, #{row} is #{cell}, liveNeighbors: #{liveNeighbors}" if @debug
  
  if cell == @live
  # Rule 1: living with less than 2 neighbors, dies
  # Rule 2: living with more than 3 neighbors, dies
  # Rule 3: living with 2 or 3 neighbors, lives
    puts " is live" if @debug
    flipCell(col, row) if (liveNeighbors < 2 || liveNeighbors > 3)
  else
  # Rule 4: dead with 3 neighbors, lives
    puts " is dead" if @debug
    flipCell(col, row) if liveNeighbors == 3
  end

end


def startWorld
  for i in 0..@start
    cell = Kernel.rand(@size * @size)
    col = cell / @size
    row = cell % @size

    flipCell(col, row)
  end

  printWorld
  writeWorld("begin.txt")
  sleep 1
  puts "GO"
  sleep 1
end

def printWorld
  system "clear"
  @world.each { |line| puts line.join("  ") }

end

def writeWorld( filename )
  Dir.chdir(File.dirname(__FILE__))
  File.open("#{Dir.pwd}/plays/#{@currentPlay}/#{filename}", 'w') { |file| file.write(printWorld) }
end

startWorld

for cycle in 0..@cycles
  system "clear"
  
  for i in 0..@size-1
    for j in 0..@size-1
      rules(i, j)
    end
  end

  filename = "%05d" % cycle
  writeWorld(filename + ".txt" )
  printWorld

  isDead = @world <=> @deadWorld
  isSame = @world <=> @oldWorld

  if isDead == 0 
    puts "They're dead Jim! (on cycle #{cycle})"
    Kernel.exit
  elsif isSame == 0
    puts "No changes (on cycle #{cycle})"
    Kernel.exit
  else
    puts cycle
  end
  
  @oldWorld = Array.new
  @world.each { |r| @oldWorld.push(r.dup) }

  sleep @pause 
end
