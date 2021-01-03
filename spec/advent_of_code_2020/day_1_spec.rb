require 'processor'
require 'assembler'

def day_1
  Assembler.run do
    copyla 0x00
    comout
    comout
    comout
    comin
    comin
    comin
    comin
    comout
  end
end

describe 'day 1' do
  [
    [[0x00,0x00,0x00,0x02], [0x00,0x00,0x00,0x01], [0x00,0x00,0x00,0x02]],
    [[0x00,0x00,0x00,0x04], [0x00,0x00,0x00,0x01], [0x00,0x00,0x00,0x04]],
    [[0x00,0x00,0x00,0x04], [0x00,0x00,0x00,0x02], [0x00,0x00,0x00,0x08]],
  ].each do |first,second,answer|
    it 'can multiply two 32bit numbers' do
      processor = day_1
      first.each { |byte| processor.send_com(byte) }
      second.each { |byte| processor.send_com(byte) }

      processor.until_finished
      
      expect(processor.receive_com).to eq(answer)
    end
  end
end
