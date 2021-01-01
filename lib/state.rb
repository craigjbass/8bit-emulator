class State
  attr_accessor :program_counter, :ram, :running

  def initialize
    @program_counter = 0x00
    @ram = (0x00..0xFF).map { 0x00 } 
    @running = false
  end

  def data
    @ram[@program_counter]
  end
end
