class Assembler
  class InvalidOperands < RuntimeError; end
  class NoSuchInstruction < RuntimeError; end

  attr_reader :end_of_program, :processor

  def initialize(processor)
    @processor = processor
    @mappings = {
      halt: [0x00, 0],
      nop: [0x01, 0],
      jump: [0x28, 1],
      copyla: [0x04, 1],
      copylr: [0x05, 2],
      copyar: [0x07, 1],
      copyra: [0x09, 1],
      copyrr: [0x0A, 2],
      addla: [0x11, 1],
      addra: [0x12, 1],
      mul: [0x15, 2],
      bclr: [0x23, 2],
      bset: [0x24, 2],
      decr: [0x1D, 1],
      decrjz: [0x1F, 1],
      comin: [0xC1, 0],
      comout: [0xC0, 0],
    }
  end

  def self.run(&block)
    assembler = self.create()
    assembler.run(&block)
    assembler.processor
  end

  def self.create
    processor = Processor.new
    self.new(processor)
  end

  def run(&block)
    initial = @processor.program_counter
    instance_eval(&block)
    @end_of_program = @processor.program_counter
    @processor.goto initial
    @processor.start
  end

  def label
    @processor.program_counter
  end

  def method_missing(method, *operands)
    instruction = @mappings[method]
    raise NoSuchInstruction.new(method) if instruction.nil?

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

