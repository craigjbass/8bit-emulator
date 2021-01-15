require 'digirule'

describe Digirule do
  let(:digirule) do
    digirule = described_class.new 
    digirule.connect('/dev/ttyS3')
    digirule
  end

  after do
    digirule.close
  end

  it 'can connect to serial port and program counter to 0x00' do
    expect(digirule.program_counter).to eq(0x00)
  end

  it 'can halt' do
    digirule.start

    expect(digirule.halted?).to be(true)
    expect(digirule.program_counter).to be(0x01)
  end
  
  it 'can halt twice' do
    digirule.start
    digirule.start

    expect(digirule.halted?).to be(true)
    expect(digirule.program_counter).to be(0x02)
  end

  it 'has empty ram' do
    (0x00..0xFF).each do |memory_location|
      expect(digirule.ram_at(memory_location)).to eq(0x00)
    end
  end

  it 'can have ram set' do
    digirule.store 0x01
    expect(digirule.ram_at 0x00).to eq(0x01)
    (0x01..0xFF).each do |address|
      expect(digirule.ram_at(address)).to eq(0x00), "checked #{address}"
    end
  end

  it 'advances program counter when ram set' do
    digirule.store 0x01
    expect(digirule.program_counter).to eq(0x01)
  end

  it 'can goto ram location' do
    digirule.goto 0x2F
    expect(digirule.program_counter).to eq(0x2F)
  end

  it 'can nop and not halt' do
    digirule.store 0x01
    digirule.store 0x01
    digirule.goto 0x00
    digirule.start 
    digirule.continue_for(1)
    expect(digirule.program_counter).to eq(0x02)
  end

  it 'can jump' do
    digirule.goto 0x01
    digirule.store 0x28
    digirule.goto 0x00
    expect(digirule.program_counter).to eq(0x00)
    digirule.start
    expect(digirule.program_counter).to eq(0x01)
    digirule.start
    digirule.continue_for(1)
    expect(digirule.program_counter).to eq(0x01)
  end

  it 'can jump to 0x05 and halt' do
    digirule.store 0x28
    digirule.store 0x05
    digirule.goto 0x00
    digirule.start
    expect(digirule.program_counter).to eq(0x05)
    digirule.start
    expect(digirule.program_counter).to eq(0x06)
  end
end
