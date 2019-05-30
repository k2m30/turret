require 'rubyserial'
require 'artoo'

connection :joystick, :adaptor => :joystick
device :joystick, :driver => :joystick, :connection => :joystick, :interval => 0.05

def read_grbl
  response = ""
  begin
    r = $grbl.read(10)
    response << r
  end until r == ""
  response
end

def normalize(val)
  if val < -8192
    val + 8192
  elsif val >= -8192 and val <= 8192
    0
  else
    val - 8192
  end
end

def sign(n)
  n <=> 0
end

# $grbl = Serial.new '/dev/cu.SLAB_USBtoUART', 115200
# $grbl = Serial.new '/dev/cu.usbmodem14201', 115200
# $grbl.write("$$\n")
sleep 0.1

# puts read_grbl

work do
  on joystick, joystick: proc {|caller, value|
    # puts 'joystick ' + value[:s].to_s, value[:x], value[:y]
    if value[:s].zero?
      # puts value
      x = normalize(value[:x])
      y = normalize(value[:y])
      # x_smooth = x * 90.0 / 24576
      # y_smooth = y * 90.0 / 24576
      # p [x, y]
      f = Math.sqrt(x ** 2 + y ** 2)
      command = "$J=G91 X#{-30 * x / 24576} Y#{30 * y / 24576} F#{f * 2.0}\n"
      # p command
      # $grbl.write command unless f.zero?
      # sleep 0.03
      # response = read_grbl.gsub("ok", '')
      # print response

      # $grbl.write "?\n"
      sleep 0.03
      # response = read_grbl.gsub("ok", '')
      # print response
    end
  }
  on joystick, button_0: proc {|*value|
    puts value
    case value[1].to_i
    when 0
      # ring
      # $grbl.write 'M7'
      # sleep 0.05
      # $grbl.write 'M8'
    when 2
      # smoke
      # $grbl.write 'M3'
      # sleep 0.05
      # $grbl.write 'M4'
    else
      puts
    end
  }
end