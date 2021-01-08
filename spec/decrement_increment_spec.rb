require 'processor'
require 'assembler'

describe '*CR instructions' do
  [
    [0x02, 0x01],
    [0x00, 0xFF],
  ].each do |starting, result|
    it 'can decrement' do
        address = rand(0xEA..0xFA)
        processor = Assembler.run do
          copylr starting, address
          bclr 0x00, 0xFC
          decr address
        end
        processor.until_finished
        expect(processor.ram_at(address)).to eq(result)
        expect(processor.ram_at(0xFC)[0]).to eq(0)
    end
  end
end
