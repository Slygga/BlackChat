#!/usr/bin/ruby

require 'socket'

class BlackServer
	@@clients = {}
	def initialize(port = 8585)
		@server = TCPServer.open(port)

		puts "Starting server on port #{port}"
		puts "Beginning listener"
		
		listener()
	end

	def listener()
		speak = nil

		while (client = @server.accept) do
			username = client.readline.chomp.strip
			@@clients.store(client, username)
			messageclients("#{username} just connected to the server.")
			puts "#{username} just connected to the server."
			puts "Starting their instance.."

			speak = Thread.new do
				echo(client)
			end
		end

		speak.join
	end

	def echo(client)
		while(message = client.recv(4096)) do
			break if message.empty?
			messageclients("#{@@clients[client]}: #{message}")
			puts("#{@@clients[client]}: #{message}")
		end
		messageclients("#{@@clients[client]} disconnected.")
		puts "#{@@clients[client]} disconnected."
		@@clients.delete(client)
	end

	def messageclients(message)
		@@clients.each_key do |client|
			client.print("#{message.chomp.strip}\n")
		end
	end
end

server = BlackServer.new(9595)