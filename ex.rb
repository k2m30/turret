require 'rubyserial'
require 'artoo'

connection :joystick, :adaptor => :joystick
device :controller, :driver => :xbox360, :connection => :joystick, :interval => 0.1

def read_grbl
  response = ""
  begin
    r = $grbl.read(10)
    response << r
  end until r == ""
  response
end

def get_response(print_response = true)
  sleep 0.03
  response = read_grbl.gsub("ok", '')
  print response if print_response
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

serial_port = ENV['RPI'].nil? ? '/dev/cu.SLAB_USBtoUART' : '/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0'
$grbl = Serial.new serial_port, 115200
# $grbl = Serial.new '/dev/cu.usbmodem14201', 115200
$grbl.write("$$\n")
get_response

$grbl.write("$X\n")
get_response

sleep 5

work do
  on controller, joystick_0: proc {|*value|
    # puts "#{value}"
    x = normalize(value[1][:x])
    y = normalize(value[1][:y])
    f = Math.sqrt(x ** 2 + y ** 2)
    command = "$J=G91 X#{-30 * x / 24576} Y#{30 * y / 24576} F#{f * 2.0}\n"
    unless f.zero?
      p command
      $grbl.write command
      get_response
      $grbl.write "?\n"
      get_response false
    end

  }
  on controller, :button_dpad_left => proc { |*value|
    puts "ring down"
    $grbl.write "M4\n"
    get_response
  }
  on controller, :button_up_dpad_left => proc { |*value|
    puts "ring up"
    $grbl.write "M3\n"
    get_response
  }
  on controller, :button_dpad_up => proc { |*value|
    puts "smoke down"
    $grbl.write "M8\n"
    get_response
  }
  on controller, :button_up_dpad_up => proc { |*value|
    puts "smoke up"
    $grbl.write "M9\n"
    get_response
  }
end