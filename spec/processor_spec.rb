require 'processor'

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

  it 'can recognise invalid memory values (upper bound)' do
    processor.store 0xFF + 1
    expect do
      processor.start
    end.to raise_error(State::MemoryHasInvalidValue)
  end

  it 'can recognise invalid memory values (lower bound)' do
    processor.store 0x00 - 1
    expect do
      processor.start
    end.to raise_error(State::MemoryHasInvalidValue)
  end
end


   
