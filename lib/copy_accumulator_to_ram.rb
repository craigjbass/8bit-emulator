class CopyAccumulatorToRam
  def initialize(state)
    @state = state
  end
  
  def run
    @state.next
    address = @state.next
    @state.ram[address] = @state.accumulator
    @state.set_zero_bit
  end
end
