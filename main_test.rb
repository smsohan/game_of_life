require 'minitest/autorun'

class Universe
  DEAD = 0
  ALIVE = 1

  def initialize(rows, columns)
    @rows = rows
    @columns = columns
    @lives =  init_with_dead
  end

  def init_with_dead
    Array.new(@rows * @columns).fill(DEAD).each_slice(@columns).to_a
  end

  def alive?(row, column)
    if row < 0 || row >= @rows || column < 0 || column >= @columns
      false
    else
      @lives[row][column] == ALIVE
    end
  end

  def alive(row, column)
    @lives[row][column] = ALIVE
  end

  def dead(row, column)
    @lives[row][column] = DEAD
  end

  def tick
    new_generation = init_with_dead

    0.upto(@rows-1) do |row|
      0.upto(@columns-1) do |column|
        new_generation[row][column] = updated_state(row, column)
      end
    end

    @lives = new_generation
  end

  private

  def updated_state(row, column)
    neighbours = neighbours(row, column)

    new_state = @lives[row][column]
    live_neighbours = neighbours.select{|nrow, ncolumn| alive?(nrow, ncolumn)}

    if alive?(row, column)
      if live_neighbours.size < 2 || live_neighbours.size > 3
        new_state = DEAD
      else
        new_state = ALIVE
      end
    elsif live_neighbours.size == 3
      new_state = ALIVE
    end


    new_state
  end

  def neighbours(row, column)
    [row, row-1, row+1].product([column, column-1, column + 1]) - [[row, column]]
  end
end

describe Universe do
  before do
    @universe = Universe.new(3, 3)
  end

  describe '#constructor' do
    it 'marks all cells as dead' do
      0.upto(2).each do |row|
        0.upto(2).each do |column|
          @universe.alive?(row, column).must_equal false
        end
      end
    end
  end

  describe 'Any live cell with fewer than two live neighbours dies, as if caused by under-population.' do
    it 'kills when only one cell is alive' do
      @universe.alive(0, 0)

      @universe.tick

      @universe.alive?(0, 0).must_equal false
    end

    it 'kills when only one neighbout is alive' do
      @universe.alive(0, 0)
      @universe.alive(0, 1)

      @universe.tick

      @universe.alive?(0, 0).must_equal false
    end
  end

  describe 'Any live cell with two or three live neighbours lives on to the next generation.' do
    it 'lives through next when 2 neighbours alive' do
      @universe.alive(0, 0)

      @universe.alive(0, 1)
      @universe.alive(1, 1)

      @universe.tick

      @universe.alive?(0, 0).must_equal true
    end

    it 'lives through next when 3 neighbours alive' do
      @universe.alive(0, 0)

      @universe.alive(0, 1)
      @universe.alive(1, 1)
      @universe.alive(1, 0)

      @universe.tick

      @universe.alive?(0, 0).must_equal true
    end
  end

  describe 'Any live cell with more than three live neighbours dies on to the next generation.' do
    it 'lives through next with 4 live neighbours' do
      @universe.alive(1, 1)

      @universe.alive(0, 1)
      @universe.alive(0, 0)
      @universe.alive(2, 0)
      @universe.alive(2, 1)

      @universe.tick

      @universe.alive?(1, 1).must_equal false
    end

    it 'lives through next with 5 live neighbours' do
      @universe.alive(1, 1)

      @universe.alive(0, 1)
      @universe.alive(0, 0)
      @universe.alive(2, 0)
      @universe.alive(2, 1)
      @universe.alive(2, 2)

      @universe.tick

      @universe.alive?(1, 1).must_equal false
    end
  end

  describe 'Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.' do

    it 'brings dead to alive with 3 alive neighbours' do
      @universe.dead(1, 1)

      @universe.alive(0, 1)
      @universe.alive(0, 0)
      @universe.alive(2, 0)

      @universe.tick

      @universe.alive?(1, 1).must_equal true
    end

    it 'stays dead with 2 live neighbours' do
      @universe.dead(1, 1)

      @universe.alive(0, 1)
      @universe.alive(0, 0)

      @universe.tick

      @universe.alive?(1, 1).must_equal false
    end

    it 'stays dead with 4 live neighbours' do
      @universe.dead(1, 1)

      @universe.alive(0, 1)
      @universe.alive(0, 0)
      @universe.alive(2, 0)
      @universe.alive(2, 1)

      @universe.tick

      @universe.alive?(1, 1).must_equal false
    end

  end



end