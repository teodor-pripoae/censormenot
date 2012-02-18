require 'net/http'
require 'socket'

scheduler = Rufus::Scheduler.start_new

def send_request(request)
  # Send multicast packet containing a query
  multicast_addr = "225.192.192.192"
  port = 25192

  begin
    socket = UDPSocket.open
    socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [255].pack('i'))
    socket.send("censormenot|q|#{request.domain}", 0, multicast_addr, port)
  ensure
    socket.close
  end
  
end

scheduler.in("0s") do
  while true
    RequestedDomain.all.each do | request |
      send_request request
      sleep 10
    end
    sleep 10
  end
end
