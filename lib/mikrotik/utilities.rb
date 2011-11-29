# @private
class Mikrotik::Utilities

  def self.hex_to_bin(input)
    padding = input.size.even? ? '' : '0'
    [padding + input].pack('H*')
  end
  
  def self.bytepack(num, size)
    s = String.new
    s.force_encoding(Encoding::BINARY) if RUBY_VERSION >= '1.9.0'    
    x = num < 0 ? -num : num  # Treat as unsigned
    while size > 0
      size -= 1
      s = (x & 0xff).chr + s
      x >>= 8
    end
    raise RuntimeError, "Number #{num} is too large to fit in #{size} bytes." if x > 0
    return s
  end

end
