require 'processor'

class DigiruleDsl
  class InvalidOperands < RuntimeError; end
  class NoSuchInstruction < RuntimeError; end

  def initialize(processor)
    @processor = processor
    @mappings = {
      halt: [0x00, 0],
      nop: [0x01, 0],
      jump: [0x28, 1],
    }
  end

  def self.run(&block)
    processor = Processor.new
    self.new(processor).run(&block)
    processor
  end

  def run(&block)
    initial = @processor.program_counter
    instance_eval(&block)
    @processor.goto initial
    @processor.start
  end

  def method_missing(method, *operands)
    instruction = @mappings[method]
    raise NoSuchInstruction if instruction.nil?

    raise_if_unexpected_operands(instruction, operands)

    instruction_opcode = instruction[0]
    @processor.store instruction_opcode

    operands.each do |operand|
      @processor.store operand
    end
  end

  def raise_if_unexpected_operands(instruction, operands)
    expected_number_of_operands = instruction[1] 
    raise InvalidOperands if operands.length != expected_number_of_operands 
  end
end

class ProcessorSpy
  attr_reader :machine_code

  def initialize
    @machine_code = []
  end

  def program_counter
  end

  def goto(address)
  end
  
  def start
  end

  def store(data)
    @machine_code << data
  end
end

describe DigiruleDsl do
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
end
