class ComIn
  def initialize(state)
    @state = state
  end

  def run
    while !@state.com_data_available?
      Fiber.yield
    end
    @state.next
    @state.accumulator = @state.receive_com
  end
end
