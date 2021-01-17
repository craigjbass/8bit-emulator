require 'processor'
require 'assembler'
require 'repeat_for_both_implementations'

describe 'ADD* instructions' do
  repeat_for_both_implementations do
    let(:assembler) { Assembler.new(processor) }

    [
      [0x00, 0x01, 0x01, 0],
      [0x20, 0x05, 0x25, 0],
      [0xFF, 0x01, 0x00, 1],
    ].each do |starting, add_amount, answer, zero_bit|
      it 'can ADDLA' do
        processor = assembler.run do
          copyla starting
          bclr 0x00, 0xFC
          addla add_amount
        end
        processor.until_finished
        expect(processor.accumulator).to eq(answer)
        expect(processor.ram_at(0xFC)[0]).to eq(zero_bit)
      end

      it 'can ADDRA' do
        processor = assembler.run do
          copyla starting
          copylr add_amount, 0xFA
          bclr 0x00, 0xFC
          addra 0xFA
        end
        processor.until_finished
        expect(processor.accumulator).to eq(answer)
        expect(processor.ram_at(0xFC)[0]).to eq(zero_bit)
      end
    end

    it 'can ADDLA Carry' do
      processor = assembler.run do
          copyla 0x00
          bset 0x01, 0xFC
          addla 0x00
        end
        processor.until_finished
        expect(processor.accumulator).to eq(0x01)
    end

    it 'can ADDLA set the carry flag' do
      processor = assembler.run do
        copyla 0xFF
        bclr 0x01, 0xFC
        addla 0x01
      end
      processor.until_finished
      expect(processor.accumulator).to eq(0x00)
      expect(processor.ram_at(0xFC)[1]).to eq(1)
    end

    it 'can ADDRA Carry' do
      processor = assembler.run do
        copyla 0x00
        copylr 0x00, 0xFA
        bset 0x01, 0xFC
        addra 0xFA
      end
      processor.until_finished
      expect(processor.accumulator).to eq(0x01)
    end

    it 'can ADDRA set the carry flag' do
      processor = assembler.run do
        copyla 0xFF
        copylr 0x01, 0xFA
        bclr 0x01, 0xFC
        addra 0xFA
      end
      processor.until_finished
      expect(processor.accumulator).to eq(0x00)
      expect(processor.ram_at(0xFC)[1]).to eq(1)
    end
  end
end
