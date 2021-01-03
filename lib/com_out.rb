class ComOut
  def initialize(state)
    @state = state
  end
  
  def run
    @state.com_out_buffer << @state.accumulator
    @state.next
  end
end
