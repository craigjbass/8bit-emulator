require 'repeat_for_both_implementations'

describe 'COM* instructions' do
  it 'can block indefinitely' do
    processor = Assembler.run do
      comin
    end
    processor.continue_for(255)
    expect(processor.program_counter).to eq(0x00)
  end

  repeat_for_both_implementations do
    let(:assembler) { Assembler.new(processor) }

    it 'can block on COMIN' do
      processor = assembler.run do
        comin
      end
      expect(processor.program_counter).to eq(0x00)
    end

    it 'can move com data to accumulator', focus: true do
      processor.send_com(0xFE)
      processor = assembler.run do
        comin
      end
      processor.continue_for(1)
      expect(processor.program_counter).to eq(0x01)
      expect(processor.accumulator).to eq(0xFE)
    end

    it 'can read data from comin buffer FIFO' do
      processor = assembler.run do
        comin
        comin
      end
      processor.send_com(0x21)
      processor.send_com(0x38)
      processor.continue_for(1)
      expect(processor.accumulator).to eq(0x21)
      processor.continue_for(1)
      expect(processor.accumulator).to eq(0x38)
    end

    xit 'can output one character to com port' do
      processor = assembler.run do
        copyla 0x28
        comout 
      end.until_finished
      data = processor.receive_com
      expect(data).to eq([0x28])
      expect(processor.program_counter).to eq(0x04)
    end
  end
end
