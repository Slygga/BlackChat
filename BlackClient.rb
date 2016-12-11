require 'socket'

hostname = 'localhost'
port = 9595

def getmessages()
	fork do
		while line = $s.readline
			puts line.chop
		end
	end
end

def sendmessages()
	fork do
		while line = gets
			$s.print(line)
		end
	end
end

$s = TCPSocket.open(hostname, port)
$s.print("Admin\n")

getmessages()
sendmessages()

Process.wait

$s.close