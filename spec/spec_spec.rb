require 'fiber'

class Instruction
  def initialize(state)
    @state = state
  end
end

class Nop < Instruction
  def run
    @state.program_counter += 1
  end
end

class Halt < Instruction
  def run
    @state.running = false
    @state.program_counter += 1
  end
end

class Jump < Instruction
  def run
    pc = @state.program_counter
    operand = @state.ram[pc + 1]
    @state.program_counter = operand
  end
end

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


describe Processor do
  let(:processor) { described_class.new }
  it 'starts with program counter at 0x00' do
    expect(processor.program_counter).to be(0x00)
  end

  it 'can halt' do
    processor.start

    expect(processor.halted?).to be(true)
    expect(processor.program_counter).to be(0x01)
  end

  it 'can halt twice' do
    processor.start
    processor.start

    expect(processor.halted?).to be(true)
    expect(processor.program_counter).to be(0x02)
  end

  it 'has empty ram' do
    (0x00..0xFF).each do |memory_location|
      expect(processor.ram_at(memory_location)).to eq(0x00)
    end
  end

  it 'can have ram set' do
    processor.store 0x01
    expect(processor.ram_at 0x00).to eq(0x01)
    (0x01..0xFF).each do |address|
      expect(processor.ram_at(address)).to eq(0x00)
    end
  end

  it 'advances program counter when ram set' do
    processor.store 0x01
    expect(processor.program_counter).to eq(0x01)
  end

  it 'can goto ram location' do
    processor.goto 0x2F
    expect(processor.program_counter).to eq(0x2F)
  end

  it 'can nop and not halt' do
    processor.store 0x01
    processor.goto 0x00
    processor.start 
    expect(processor.halted?).to be(false)
  end

  it 'can nop and halt' do
    processor.store 0x01
    processor.goto 0x00
    processor.start 
    expect(processor.program_counter).to eq(0x01)
    processor.continue_for(1)
    expect(processor.program_counter).to eq(0x02)
  end

  it 'can jump' do
    processor.goto 0x01
    processor.store 0x28
    processor.goto 0x00
    expect(processor.program_counter).to eq(0x00)
    processor.start
    expect(processor.program_counter).to eq(0x01)
    processor.start
    processor.continue_for(1)
    expect(processor.program_counter).to eq(0x01)
  end

  it 'can jump to 0x05 and halt' do
    processor.store 0x28
    processor.store 0x05
    processor.goto 0x00
    processor.start
    expect(processor.program_counter).to eq(0x05)
    processor.continue_for 1
    expect(processor.program_counter).to eq(0x06)
  end
end


   
