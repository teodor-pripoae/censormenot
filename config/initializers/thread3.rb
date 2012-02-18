require 'net/http'
require 'socket'

def send_answer(answer)
  # Send multicast packet containing a query
  multicast_addr = "225.192.192.192"
  port = 25192

  begin
    socket = UDPSocket.open
    socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [255].pack('i'))
    socket.send(answer.to_answer, 0, multicast_addr, port)
  rescue

  ensure
    socket.close
  end
  
end


if RUNNING_SERVER
  scheduler = Rufus::Scheduler.start_new

  scheduler.in("0s") do
    multicast_addr = "225.192.192.192"
    port = 25193

    ip =  IPAddr.new(multicast_addr).hton + IPAddr.new("0.0.0.0").hton

    sock = UDPSocket.new
    sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
    sock.bind(Socket::INADDR_ANY, port)
    
    loop do
      msg, info = sock.recvfrom(1024)
      puts "Received Query"
      if not valid_query? msg, info
        puts "Query not valid"
        next
      end

      data = msg.split('|')

      answer = Lookup.where(:domain => data[2]).order("trust DESC").first
      if not answer.nil?
        send_answer answer
        puts "Answered query with #{answer.to_answer}"
      else
        puts "Didn't find any data for domain:  #{data[2]}"
      end
    end
  end
end
