require 'fiber'
require 'instruction'
require 'halt'
require 'jump'
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
    }
  end

  def start
    @state.running = true
    @fiber = Fiber.new do
      while @state.running
        Fiber.yield
        @instructions[@state.data].new(@state).run
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

  def halted?
    !@state.running
  end

  def program_counter
    @state.program_counter
  end
end
