#!/usr/bin/env ruby

require 'socket'

class DebuggerCmd
  class << self
    attr_reader :not_running
    def socket
      return if @not_running
      @socket ||= TCPSocket.new('localhost', 8990)
    rescue Errno::ECONNREFUSED
      puts "Debugger is not running."
      @not_running = true
    end
  end
  
  def initialize
    socket
  end
  
  def socket
    self.class.socket
  end
  
  def send_command(cmd, msg = nil)
    return if self.class.not_running
    begin
      socket.gets
      socket.puts cmd
      puts msg if msg
    rescue Exception
      puts "Error: #{$!.class}"
    end
  end

  def output
    return if self.class.not_running
    result = ""
    while line = socket.gets
      break if line =~ /^PROMPT/
      result << line
    end
    result
  rescue Exception
    puts "Error: #{$!.class}"
  end
  
  def print_output
    return if self.class.not_running
    puts output
  end
end

at_exit do
  begin
    DebuggerCmd.socket.close if DebuggerCmd.socket
  rescue Exception
  end
end
