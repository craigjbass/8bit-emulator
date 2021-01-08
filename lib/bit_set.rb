class BitSet
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    bit = @state.next
    address = @state.next

    mask = 0x02.pow(bit % 8)

    current = @state.ram[address]

    @state.ram[address] = current | mask
  end
end
