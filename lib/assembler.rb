class Assembler
  class InvalidOperands < RuntimeError; end
  class NoSuchInstruction < RuntimeError; end

  def initialize(processor)
    @processor = processor
    @mappings = {
      halt: [0x00, 0],
      nop: [0x01, 0],
      jump: [0x28, 1],
      copyla: [0x04, 1],
      comin: [0xC1, 0],
      comout: [0xC0, 0],
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

  def label
    @processor.program_counter
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

