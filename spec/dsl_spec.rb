require 'processor'
require 'assembler'

class ProcessorSpy
  attr_reader :machine_code

  def initialize
    @machine_code = []
  end

  def program_counter
    0x00
  end

  def goto(address)
  end
  
  def start
  end

  def store(data)
    @machine_code << data
  end
end

describe Assembler do
  it 'fails on missing instruction' do
    expect do 
      described_class.run do
        this_does_not_exist
      end
    end.to raise_error(described_class::NoSuchInstruction)
  end

  it 'can nop' do
    processor = described_class.run do
      nop
    end
    expect(processor.halted?).to be(false)
  end

  it 'can halt' do
    spy = ProcessorSpy.new
    described_class.new(spy).run do
      halt
    end
    expect(spy.machine_code).to eq([0x00])
  end

  it 'can jump' do
    spy = ProcessorSpy.new
    described_class.new(spy).run do
      jump 0x80
    end
    expect(spy.machine_code).to eq([0x28, 0x80])
  end

  it 'can fail if missing jump operand' do
    spy = ProcessorSpy.new
    expect do
      described_class.new(spy).run do
        jump
      end
    end.to raise_error(described_class::InvalidOperands)
  end

  it 'can label' do
    spy = ProcessorSpy.new
    described_class.new(spy).run do
      beginning = label
      jump beginning
    end
    expect(spy.machine_code).to eq([0x28, 0x00])
  end
end
