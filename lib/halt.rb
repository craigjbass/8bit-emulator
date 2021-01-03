class Halt < Instruction
  def run
    @state.running = false
    @state.next
  end
end

