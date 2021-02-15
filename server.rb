require 'socket'

class HTTPParser
  attr_reader :data

  Output = Struct.new(:method, :path)

  def initialize(data)
    @data = data
  end

  def call
    method, path, _ = data.split(' ')

    Output.new(method, path)
  end
end

class PathBuilder
  attr_reader :path

  BASE_PATH = File.expand_path('../_site', __FILE__).freeze

  def initialize(path)
    @path = path
  end

  def call
    full_path = File.join(BASE_PATH, path)
    full_path = File.join(full_path, 'index.html') if File.directory?(full_path)
    full_path
  end
end

pipe = Ractor.new do
  loop do
    Ractor.yield(Ractor.recv, move: true)
  end
end

CPU_COUNT = ENV.fetch('RACTORS_COUNT', '2').to_i
MAX_REQUEST_SIZE = ENV.fetch('MAX_REQUEST_SIZE', '4096').to_i # Bytes
CONTENT_TYPES = {
  '.bin' => 'application/octet-stream',
  '.css' => 'text/css',
  '.html' => 'text/html',
  '.ico' => 'image/x-icon',
  '.js' => 'application/javascript',
  '.png' => 'image/png',
  '.txt' => 'text/plain',
  '.xml' => 'application/xml'
}.freeze
Ractor.make_shareable(CONTENT_TYPES)

workers = CPU_COUNT.times.map do
  Ractor.new(pipe) do |pipe|
    loop do
      s = pipe.take

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      ip_address = s.remote_address.ip_address

      request = HTTPParser.new(s.gets(MAX_REQUEST_SIZE)).call

      status = 200
      file_path = PathBuilder.new(request.path).call
      status, file_path = [404, PathBuilder.new('404.html').call] unless File.exist?(file_path)
      content_type = CONTENT_TYPES[File.extname(file_path)] || CONTENT_TYPES['.bin']
      body, headers = [File.read(file_path), { content_type: content_type }]

      s.print "HTTP/1.1 #{status}\r\n"
      s.print "Content-Type: #{headers[:content_type]}\r\n"
      s.print "\r\n"
      s.print body
      s.close

      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      duration = (end_time - start_time) * 1000 # Milliseconds

      puts "'ractor'='#{Ractor.current}', 'ip'='#{ip_address}', 'method'='#{request.method}, 'path'='#{request.path}', 'status'='#{status}', 'ms'='#{duration.floor(2)}'"
    end
  end
end

listener = Ractor.new(pipe) do |pipe|
  server = TCPServer.new(8080)
  loop do
    conn, _ = server.accept
    pipe.send(conn, move: true)
  end
end

loop do
  Ractor.select(listener, *workers)
  # if the line above returned, one of the workers or the listener has crashed
end

