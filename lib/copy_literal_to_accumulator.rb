class CopyLiteralToAccumulator
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    @state.accumulator = @state.next
    @state.set_zero_bit
  end
end
