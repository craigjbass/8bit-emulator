class Nop < Instruction
  def run
    @state.program_counter += 1
  end
end
