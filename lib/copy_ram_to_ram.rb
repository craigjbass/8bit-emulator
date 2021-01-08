class CopyRamToRam
  def initialize(state)
    @state = state
  end

  def run
    @state.next
    from = @state.next
    to = @state.next

    @state.ram[to] = @state.ram[from]
  end
end
