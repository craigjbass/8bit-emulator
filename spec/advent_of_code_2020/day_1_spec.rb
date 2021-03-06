require 'processor'
require 'assembler'
require 'repeat_for_both_implementations'

def day_1(processor)
  assembler = Assembler.new(processor)

  assembler.run do
    copyla 0x00
    comin
    copyar 0xE3
    comin
    copyar 0xE2
    comin
    copyar 0xE1
    comin
    copyar 0xE0
    comin
    copyar 0xE7
    comin
    copyar 0xE6
    comin
    copyar 0xE5
    comin
    copyar 0xE4
    
    here = label
    copyla 0x00
    bclr 0x01, 0xFC 
    addra 0xE8
    addra 0xE0
    copyrr 0xFC, 0xFA
    copyar 0xE8
    copyla 0x00
    bclr 0x01, 0xFC 
    addra 0xE9
    copyrr 0xFA, 0xFC
    addra 0xE1
    copyar 0xE9
    

    decrjz 0xE4
    jump here
    copyla 0x00
    copyra 0xEB
    comout
    copyra 0xEA
    comout
    copyra 0xE9
    comout
    copyra 0xE8
    comout
  end

  [assembler.processor, assembler]
end

xdescribe 'day 1' do
  repeat_for_both_implementations do
    [
      [[0x00,0x00,0x00,0x02], [0x00,0x00,0x00,0x01], [0x00,0x00,0x00,0x02]],
      [[0x00,0x00,0x00,0x04], [0x00,0x00,0x00,0x01], [0x00,0x00,0x00,0x04]],
      [[0x00,0x00,0x00,0x04], [0x00,0x00,0x00,0x02], [0x00,0x00,0x00,0x08]],
      [[0x00,0x00,0x00,0x80], [0x00,0x00,0x00,0x02], [0x00,0x00,0x01,0x00]],
      [[0x00,0x00,0x00,0xFF], [0x00,0x00,0x00,0x02], [0x00,0x00,0x01,0xFE]],
      [[0x00,0x00,0x00,0xFF], [0x00,0x00,0x00,0xFF], [0x00,0x00,0xFE,0x01]],
      [[0x00,0x00,0x00,0xFF], [0x00,0x00,0x01,0x00], [0x00,0x00,0xFF,0x00]],
    ].each do |first,second,answer|
      it 'can multiply two 32bit numbers' do
        processor, assembler = day_1(processor)
        first.each { |byte| processor.send_com(byte) }
        second.each { |byte| processor.send_com(byte) }

        processor.until_finished
        
        expect(processor.receive_com).to eq(answer)
        expect(assembler.end_of_program).to be < 0xE0
      end
    end
  end
end
