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
    mask = 0x01
    @ram[0xFC] = @ram[0xFC] | mask 
  end

  def set_carry_flag
    mask = 0x02
    @ram[0xFC] = @ram[0xFC] | mask
  end

  def carry_flag
    @ram[0xFC][1]
  end

  def send_com(byte)
    @com_data << byte
  end

  def receive_com
    @com_data.shift
  end

  def com_data_available?
    @com_data.length > 0
  end

  class MemoryHasInvalidValue < RuntimeError; end

  def integrity_check
    @ram.each_with_index do |value, address|
      raise MemoryHasInvalidValue.new("0x#{value.to_s(16)} at 0x#{address.to_s(16)} is greater than 0xFF") if value > 0xFF
      raise MemoryHasInvalidValue.new("0x#{value.to_s(16)} at 0x#{address.to_s(16)} is less than 0x00") if value < 0x00
    end
  end
end

