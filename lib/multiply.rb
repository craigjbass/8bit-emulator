class Multiply
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    product_address = @state.next
    multiplier_address = @state.next
    result = @state.ram[product_address] * @state.ram[multiplier_address]
    result = result % 256
    @state.ram[product_address] = result
  end
end
