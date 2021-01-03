class CopyLiteralToRam
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    literal = @state.next
    address = @state.next

    @state.ram[address] = literal
    @state.set_zero_bit
  end
end
