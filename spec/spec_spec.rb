require 'fiber'

class Processor
  def initialize
    @program_counter = 0x00
    @ram = (0x00..0xFF).map { 0x00 } 
    @running = false
    @fiber = nil
  end

  def start
    @running = true
    @fiber = Fiber.new do
      while @running
        Fiber.yield
        if @ram[@program_counter] == 0x28
          @program_counter = @ram[@program_counter + 0x01]
        elsif @ram[@program_counter] == 0x01
          @program_counter += 1
        elsif @ram[@program_counter] == 0x00
          @running = false
          @program_counter += 1
        end
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
    @program_counter = address
  end

  def store(byte)
    @ram[@program_counter] = byte
    @program_counter += 1
  end

  def ram_at(address)
    @ram[address]
  end

  def halted
    true
  end

  def program_counter
    @program_counter
  end
end


describe Processor do
  it 'starts with program counter at 0x00' do
    processor = described_class.new
    expect(processor.program_counter).to be(0x00)
  end

  it 'can halt' do
    processor = described_class.new
    processor.start

    expect(processor.halted).to be(true)
    expect(processor.program_counter).to be(0x01)
  end

  it 'can halt twice' do
    processor = described_class.new
    processor.start
    processor.start

    expect(processor.halted).to be(true)
    expect(processor.program_counter).to be(0x02)
  end

  it 'has empty ram' do
    processor = described_class.new
    (0x00..0xFF).each do |memory_location|
      expect(processor.ram_at(memory_location)).to eq(0x00)
    end
  end

  it 'can have ram set' do
    processor = described_class.new
    processor.store 0x01
    expect(processor.ram_at 0x00).to eq(0x01)
    (0x01..0xFF).each do |address|
      expect(processor.ram_at(address)).to eq(0x00)
    end
  end

  it 'advances program counter when ram set' do
    processor = described_class.new
    processor.store 0x01
    expect(processor.program_counter).to eq(0x01)
  end

  it 'can goto ram location' do
    processor = described_class.new
    processor.goto 0x2F
    expect(processor.program_counter).to eq(0x2F)
  end

  it 'can nop and halt' do
    processor = described_class.new
    processor.store 0x01
    processor.goto 0x00
    processor.start 
    expect(processor.program_counter).to eq(0x01)
    processor.continue_for(1)
    expect(processor.program_counter).to eq(0x02)
  end

  it 'can jump' do
    processor = described_class.new
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
    processor = described_class.new
    processor.store 0x28
    processor.store 0x05
    processor.goto 0x00
    processor.start
    expect(processor.program_counter).to eq(0x05)
    processor.continue_for 1
    expect(processor.program_counter).to eq(0x06)
  end
end


   
