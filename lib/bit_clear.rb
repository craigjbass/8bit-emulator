class BitClear
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    bit = @state.next
    address = @state.next

    mask = ~0x02.pow(bit % 0x08)

    current = @state.ram[address]

    @state.ram[address] = mask & current
  end
end
