require 'fiber'
require 'instruction'
require 'add_literal_to_accumulator'
require 'add_ram_to_accumulator'
require 'bit_clear'
require 'bit_set'
require 'com_in'
require 'com_out'
require 'copy_accumulator_to_ram'
require 'copy_literal_to_accumulator'
require 'copy_literal_to_ram'
require 'copy_ram_to_accumulator'
require 'copy_ram_to_ram'
require 'decrement'
require 'decrement_and_jump_two_if_zero'
require 'halt'
require 'jump'
require 'multiply'
require 'nop'
require 'state'

class Processor
  def initialize
    @state = State.new
    @fiber = nil
    @instructions = {
      0x00 => Halt,
      0x01 => Nop,
      0x28 => Jump,
      0x04 => CopyLiteralToAccumulator,
      0x05 => CopyLiteralToRam,
      0x07 => CopyAccumulatorToRam,
      0x09 => CopyRamToAccumulator,
      0x0A => CopyRamToRam,
      0x11 => AddLiteralToAccumulator,
      0x12 => AddRamToAccumulator,
      0x15 => Multiply,
      0x23 => BitClear,
      0x24 => BitSet,
      0x1D => Decrement,
      0x1F => DecrementAndJumpTwoIfZero,
      0xC1 => ComIn,
      0xC0 => ComOut,
    }
  end

  def start
    @state.running = true
    @fiber = Fiber.new do
      while @state.running
        Fiber.yield
        @instructions[@state.data].new(@state).run
        @state.integrity_check
      end
    end

    @fiber&.resume
    @fiber&.resume
  end

  def continue_for(instructions)
    instructions.times do 
      @fiber.resume
    end
  end

  def until_finished
    while !halted?
      @fiber.resume
    end
    self
  end

  def goto(address)
    @state.program_counter = address
  end

  def store(byte)
    @state.ram[@state.program_counter] = byte
    @state.program_counter += 1
  end

  def ram_at(address)
    @state.ram[address]
  end

  def send_com(byte)
    @state.send_com(byte)
  end

  def receive_com
    buffer = @state.com_out_buffer
    @state.com_out_buffer = []
    buffer
  end

  def halted?
    !@state.running
  end

  def data_leds
    @state.ram[0xFF]
  end

  def address_leds
    if @state.ram[0xFC][2] == 1
      return @state.ram[0xFE]
    end
    @state.program_counter
  end

  def program_counter
    @state.program_counter
  end

  def accumulator
    @state.accumulator
  end
end
