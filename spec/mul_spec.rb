describe 'MUL instruction' do
  [
    [0x02, 0x02, 0x04],
    [0x04, 0x02, 0x08],
  ].each do |first, second, answer|
    it 'can multiply' do
      processor = Assembler.run do
        copylr first, 0x20
        copylr second, 0x21
        mul 0x20, 0x21
      end
      
      processor.until_finished

      expect(processor.ram_at(0x20)).to eq(answer)
    end
  end
end
