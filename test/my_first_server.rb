require 'webrick'

server = WEBrick::HTTPServer.new(:Port => 8080)

trap('INT') { server.shutdown }

server.mount_proc("/") do |req, res|

  #if req.
  res.content_type= "text/text"
  res.body=req.path
  # res.content_type = text
#   res.body
end

#HTTPResponse.content_type



server.start #=> what??