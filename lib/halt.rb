class Halt < Instruction
  def run
    @state.running = false
    @state.program_counter += 1
  end
end

