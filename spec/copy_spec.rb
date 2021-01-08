require 'processor'
require 'assembler'

describe 'COPY* instructions' do
  [0xFF, 0x8c].each do |operand|
    it 'can COPYLA' do
      processor = Assembler.run do
        copyla operand
      end
      expect(processor.accumulator).to eq(operand)
      expect(processor.program_counter).to eq(0x02)
      expect(processor.ram_at(0xFC)[0]).to eq(1)
    end

    it 'can COPYRR' do
      address = rand(0xE0..0xEF)
      processor = Assembler.run do
        copylr operand, address
        copyrr address, address + 1
      end
      processor.until_finished
      expect(processor.ram_at(address + 1)).to eq(operand)
    end
  end

  it 'can COPYLR' do
      processor = Assembler.run do
        copylr 0x72, 0x48
      end
      processor.until_finished
      expect(processor.program_counter).to eq(0x04)
      expect(processor.ram_at(0x48)).to eq(0x72)
      expect(processor.ram_at(0xFC)[0]).to eq(1)
  end

  it 'can COPYAR' do
      processor = Assembler.run do
        copyla 0x13
        bclr 0x00, 0xFC
        copyar 0x10
      end
      processor.until_finished
      expect(processor.program_counter).to eq(0x08)
      expect(processor.ram_at(0x10)).to eq(0x13)
      expect(processor.ram_at(0xFC)[0]).to eq(1)
  end

  it 'can COPYRA' do
      processor = Assembler.run do
        copylr 0x19, 0xE0
        bclr 0x00, 0xFC
        copyra 0xE0
      end
      processor.until_finished
      expect(processor.program_counter).to eq(0x09)
      expect(processor.accumulator).to eq(0x19)
      expect(processor.ram_at(0xFC)[0]).to eq(1)
  end
end
