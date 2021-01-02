require 'processor'

describe Processor do
  let(:processor) { described_class.new }

  it 'can display empty data led register' do
    processor.store 0x01
    processor.goto 0x00
    processor.start
    expect(processor.data_leds).to eq(0b00000000) 
  end

  it 'can display data led register' do
    processor.store 0x01
    processor.goto 0xFF
    processor.store 0b10101111
    processor.goto 0x00
    processor.start
    expect(processor.data_leds).to eq(0b10101111) 
  end

  it 'can display the current address on leds' do
    processor.store 0x01
    processor.goto 0x00
    processor.start
    expect(processor.address_leds).to eq(0b00000001)
  end

  it 'can display the current address on leds 2' do
    processor.goto 0x0F
    processor.store 0x01
    processor.goto 0x0F
    processor.start
    expect(processor.address_leds).to eq(0b00010000)
  end

  it 'can display address leds register when bit is enabled' do
    processor.goto 0xFC
    processor.store 0b00000100
    processor.goto 0x0F
    processor.store 0x01
    processor.goto 0x0F
    processor.start
    expect(processor.address_leds).to eq(0b00000000)
  end

  it 'can display address leds register when bit is enabled 2' do
    processor.goto 0xFC
    processor.store 0b00000100
    processor.goto 0xFE
    processor.store 0b11101110
    processor.goto 0x0F
    processor.store 0x01
    processor.goto 0x0F
    processor.start
    expect(processor.address_leds).to eq(0b11101110)
  end
end
