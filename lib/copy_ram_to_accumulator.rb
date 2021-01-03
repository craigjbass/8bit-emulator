class CopyRamToAccumulator
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    address = @state.next
    @state.accumulator = @state.ram[address]
    @state.set_zero_bit
  end
end
