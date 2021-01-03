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
  end
end
