class Decrement
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    address = @state.next
    
    value = @state.ram[address]

    value -= 1
    value = 0xFF if value < 0

    @state.ram[address] = value
  end
end
