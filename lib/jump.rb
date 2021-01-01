class Jump < Instruction
  def run
    pc = @state.program_counter
    operand = @state.ram[pc + 1]
    @state.program_counter = operand
  end
end
