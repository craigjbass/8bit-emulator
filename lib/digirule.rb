require 'rubyserial'
require 'pry'

class Digirule
  def connect(device)
    @serial = Serial.new(device, 9600, 8, :none, 1)
    @serial.write("\r")
    prompt = @serial.gets("\r\n> ")
    unless prompt.end_with? "\r\n> "
      raise "Not a valid prompt #{prompt}"
    end

    @serial.write("F")
    @serial.gets("? ")
    @serial.write("00")
    @serial.gets("? ")
    @serial.write("FF")
    @serial.gets("? ")
    @serial.write("00")
    @serial.gets("> ")

    @serial.write("Z")
    @serial.gets("> ")
  end


  def close
    @serial.close
  end

  def start
    @serial.write("S")
    prompt = @serial.gets("\r\n> ")
    unless prompt.end_with?("> ")
      raise 'Hmm'
    end
    sleep 0.080
  end

  def continue_for(instructions)
    (0...1).each do |a|
      start
    end
  end

  def until_finished
  end

  def goto(address)
    set_program_counter(address.to_s(16).rjust(2, '0'))
  end

  def store(byte)
    pc = program_counter
    current_address = pc.to_s(16).rjust(2, '0')
    @serial.write("E")
    @serial.gets("? ")
    @serial.write(current_address)
    @serial.gets("\r\n")
    data = byte.to_s(16).rjust(2, '0')
    @serial.write(data)
    @serial.gets("? ")
    @serial.write("\r")
    @serial.gets("> ")

    set_program_counter((pc + 1).to_s(16).rjust(2, '0'))
  end

  def ram_contents
    @serial.write("D")
    lines = []
    i = 0
    until i == 16 
      lines << @serial.gets("|\r\n")
      i += 1
    end
    @serial.gets("> ")
    lines
  end

  def ram_at(address)
    @ram_contents ||= ram_contents
    matches = @ram_contents[0].scan(/[0-9A-Z]{2}/)

    memory_locations = []
    @ram_contents.each do |row|
      matches = row.scan(/[0-9A-Z]{2}/)
      memory_values = matches.drop(1)
      memory_values.each do |value|
        memory_locations << value
      end
    end

    memory_locations[address].to_i(16)
  end

  def send_com(byte)
  end

  def receive_com
  end

  def halted?
    @serial.write("R")
    thing = @serial.gets
    registers = @serial.gets
    matches = /@PC=HALT/.match(registers)

    matches.length > 0
  end

  def data_leds
    ram_at(0xFF)
  end

  def address_leds
    if ram_at(0xFC)[2] == 1
      return ram_at(0xFE)
    end
    program_counter
  end

  def program_counter
    @serial.write("R")
    thing = @serial.gets
    registers = @serial.gets
    matches = /PC=([A-F0-9]{2})/.match(registers)
    matches[1].to_i(16) 
  end

  def accumulator
  end

  private

  def set_program_counter(to)
    @serial.write("P")
    @serial.gets("? ")
    @serial.write(to)
    @serial.gets
  end
end
