class State
  attr_accessor :program_counter, :ram, :running, :accumulator, :com_out_buffer

  def initialize
    @program_counter = 0x00
    @accumulator = 0x00
    @ram = (0x00..0xFF).map { 0x00 } 
    @running = false
    @com_data = []
    @com_out_buffer = []
  end

  def data
    @ram[@program_counter]
  end

  def next
    current = data
    @program_counter += 1
    current
  end

  def set_zero_bit
    @ram[0xFC] = @ram[0xFC][0] | 0x01
  end

  def send_com(byte)
    @com_data << byte
  end

  def receive_com
    @com_data.pop
  end

  def com_data_available?
    @com_data.length > 0
  end
end
