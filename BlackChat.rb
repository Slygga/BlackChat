#!/usr/bin/ruby
require 'tk'
require 'socket'
require 'thread'

class BlackChat
	@@users = []

	def initialize()
		@root = TkRoot.new
		@root.title = "BlackChat"
		@root.minsize(450, 300)
		@root.configure("background", "gray13")

		@username = String.new("")
		@queue = Queue.new

		blackchat()
		Tk.after 500, proc{login_window()}
	end

	def blackchat()
		body = TkFrame.new(@root) do
			height 100
			width 50
			background "gray13"
			pack("side" => "top", "fill" => "both")
		end

		footer = TkFrame.new(@root) do
			pack("side" => "bottom", "fill" => "both")
		end

		@console = TkText.new(body) do
		  borderwidth 0
		  padx "5"
		  pady "5"
		  wrap "word"
		  font TkFont.new("sans 10 normal")
		  background "gray13"
		  foreground "gray87"
		  state "disabled"
		  pack("side" => "left", "fill" => "x")
		  #place("relx" => 0.0, "rely" => 0.0)
		end

		@scrollbar = TkScrollbar.new(body, "command" => proc{|*args| @console.yview *args})
		@scrollbar.configure("background", "gray87")
		@scrollbar.configure("troughcolor", "gray13")
		@scrollbar.configure("borderwidth", 0)
		@scrollbar.configure("elementborderwidth", 0)
		@scrollbar.pack('side' => 'left', 'fill' => 'y')
		@console.yscrollcommand(proc{|first, last| @scrollbar.set(first, last)})

		@input = TkEntry.new(footer) do
			borderwidth 0
			font TkFont.new("sans 10 normal")
			background "gray87"
			foreground "gray13"
			pack("side" => "bottom", "fill" => "both", "ipady" => 5, "ipadx" => 15)
			#place("relx" => 0.0, "rely" => 1.0)
		end

		@input.bind("Return") do
			if(@username.strip.empty?)
				if(@login.exist?)
					postmessage("Please select a username otherwise, you won't be using my trash.")
					@input.value = ""
					@login.raise
				else
					postmessage("Please select a username otherwise, you won't be using my trash.")
					@input.value = ""
					login_window()
				end
			else
				sendmessage(@input.get())
				@input.value = ""
			end
		end

		postmessage("Server: Welcome to BlackChat")
	end

	def login_window()
		@login = TkToplevel.new(@root) do
			title "Login"
			background "gray13"
			pady 20
			padx 20
		end

		loginlabel = TkLabel.new(@login) do
		  text "Display Name"
		  borderwidth 0
		  font TkFont.new("sans 11 normal")
		  justify "left"
		  background "gray13"
		  foreground "gray87"
		  pack("side" => "left", "fill" => "x", "padx" => 10)
		  #place("relx" => 0.0, "rely" => 0.0)
		end

		@logintext = TkEntry.new(@login) do
			borderwidth 0
			font TkFont.new("sans 10 normal")
			background "gray87"
			foreground "gray13"
			pack("side" => "right", "fill" => "both", "ipady" => 2, "ipadx" => 15)
			#place("relx" => 0.0, "rely" => 1.0)
		end

		@logintext.bind("Return") do
			@username = @logintext.get()
			postmessage("Username set to #{@username}")
			@@users.push(@username)
			@login.destroy()
			connect()
		end

		@login.raise
	end

	def connect(ip = "73.36.28.143", port = 9595)
		@server = TCPSocket.open(ip, port)
		@server.puts(@username)
		recvmessage()
	end

	def sendmessage(message)
		@server.print("#{message}\n")	
	end

	def recvmessage()
		Thread.new do
			while line = @server.readline
				postmessage(line)
			end
		end
	end

	def postmessage(message)
		@console["state"] = :normal
		@console.value += "#{message.chomp}\n"
		@console.yview("end")
		@console["state"] = :disabled
	end
end