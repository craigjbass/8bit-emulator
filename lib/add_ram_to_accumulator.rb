class AddRamToAccumulator
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    address = @state.next


    value = @state.accumulator
    value += @state.ram[address]
    value += @state.carry_flag
    if value > 0xFF 
      @state.set_carry_flag
    end
    value = value % 256
    @state.accumulator = value
    if value == 0
      @state.set_zero_bit
    end
  end
end
