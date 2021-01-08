require 'processor'
require 'assembler'

describe 'B* (bit) instructions' do
  [
    [
      0b11111111,
      0x07,
      0b01111111
    ],
    [
      0b11111111,
      0x00,
      0b11111110
    ],
    [
      0b11111111,
      0x08,
      0b11111110
    ],
    [
      0b11111111,
      0x0F,
      0b01111111
    ],
  ].each do |starting, bit_to_clear, result|
    it 'can BCLR' do
      address = rand(0x10..0xFA)
      processor = Assembler.run do
        copylr starting, address
        bclr bit_to_clear, address
      end
      processor.until_finished
      expect(processor.ram_at(address)).to eq(result)
    end
  end

  [
    [0b00000000, 0x00, 0b00000001],
    [0b00000000, 0x01, 0b00000010],
    [0b11110000, 0x01, 0b11110010],
    [0b01110000, 0x0F, 0b11110000],
  ].each do |starting, bit_to_set, result| 
    it 'can BSET' do
      address = rand(0x10..0xFA)
      processor = Assembler.run do
        copylr starting, address 
        bset bit_to_set, address
      end
      processor.until_finished

      expect(processor.ram_at(address)).to eq(result)
    end
  end
end
