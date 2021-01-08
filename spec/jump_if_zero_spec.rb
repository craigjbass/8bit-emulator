require 'processor'
require 'assembler'

describe '*CRJZ instructions' do
  [
    [0x02, 0x01],
    [0x00, 0xFF],
  ].each do |starting, result|
    it 'can decrement' do
        jump_to = 0xAA
        here = nil
        address = rand(0xEA..0xFA)
        processor = Assembler.run do
          copylr starting, address
          bclr 0x00, 0xFC
          decrjz address
          jump jump_to
          here = label
        end
        processor.until_finished
        expect(processor.program_counter).to eq(jump_to + 1)
        expect(processor.ram_at(address)).to eq(result)
        expect(processor.ram_at(0xFC)[0]).to eq(0)
    end
  end
  
  it 'can advance program counter by two when zero' do
      here = nil
      address = rand(0xEA..0xFA)
      processor = Assembler.run do
        copylr 0x01, address
        bclr 0x00, 0xFC
        decrjz address
        jump 0xAA
        halt
        here = label
      end
      processor.until_finished
      expect(processor.program_counter).to eq(here)
      expect(processor.ram_at(address)).to eq(0x00)
      expect(processor.ram_at(0xFC)[0]).to eq(1)
  end
end
