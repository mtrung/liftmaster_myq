#!/usr/bin/env ruby
# test application for liftmaster_myq

require 'liftmaster_myq'

def printList(prefix, list)
  if list.nil?
    puts "#{prefix}: nil"
  elsif list.respond_to?("each")
    # @names is a list of some kind, iterate!
    puts "#{prefix} list has #{list.count} items:"
    list.each do |listItem|
      puts "- #{listItem}"
    end
  else
    puts "#{prefix}: #{list}"
  end
end

class Gdo
  attr_accessor :system

  # Create the object
  def initialize()
      @system = LiftmasterMyq::System.new('xxx@gmail.com','xxx')
      puts "LiftmasterMyq ver #{LiftmasterMyq::VERSION}"
      puts " "
      printList(".gateways", @system.gateways)
      printList(".garage_doors", @system.garage_doors)
    #   printList(".lights", @system.lights)
      puts " "
  end

  def getDoorStatus(door)
    #   puts "door status: #{door.status}"

    isStoppedState = (door.status == 'closed' or door.status == 'open') ? true : false

    if @lastDoorStatus.nil?
        print "   " + door.status
    elsif door.status == @lastDoorStatus
        print "."
    else
        if isStoppedState == true
            puts "]"
            puts "   " + door.status + " :)"
        else
            puts "]"
            print "   [" + door.status
        end
    end

    @lastDoorStatus = door.status
    return isStoppedState
  end

  def getDoorsStatus()
    if @system.garage_doors.respond_to?("each")
        @system.garage_doors.each do |door|
            while getDoorStatus(door) == false
                sleep 1
            end
        end
    end
  end

  def getDefaultDoor()
      return @system.garage_doors[0]
  end

  def toggle()
    door = getDefaultDoor
    statusStr = "   " + door.status
    if door.status == 'closed'
        statusStr += " => open"
        door.open
    elsif door.status == 'open'
        statusStr += " => closed"
        door.close
    else
        # ignore other states
        statusStr += "..."
    end
    puts statusStr
  end

end

if __FILE__ == $0
  gdo = Gdo.new
  param1 = ARGV[0]

  $stdout.sync = true

  if param1.nil?
      gdo.getDoorsStatus
      exit
  end

  gdo.toggle

  # wait until status changes
  door = gdo.getDefaultDoor
  while gdo.getDoorStatus(door) == true
      sleep 1
  end

  gdo.getDoorsStatus
end
