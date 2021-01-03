describe 'COM* instructions' do
  it 'can block on COMIN' do
    processor = Assembler.run do
      comin
    end
    expect(processor.program_counter).to eq(0x00)
  end

  it 'can block indefinitely' do
    processor = Assembler.run do
      comin
    end
    processor.continue_for(255)
    expect(processor.program_counter).to eq(0x00)
  end

  it 'can move com data to accumulator' do
    processor = Assembler.run do
      comin
    end
    processor.send_com(0xFE)
    processor.continue_for(1)
    expect(processor.program_counter).to eq(0x01)
    expect(processor.accumulator).to eq(0xFE)
  end

  it 'can output one character to com port' do
    processor = Assembler.run do
      copyla 0x28
      comout 
    end.until_finished
    data = processor.receive_com
    expect(data).to eq([0x28])
    expect(processor.program_counter).to eq(0x04)
  end
end
