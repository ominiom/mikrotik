# @private
class String

  def to_mikrotik_word
     str = self.dup
     if RUBY_VERSION >= '1.9.0'
       str.force_encoding(Encoding::BINARY)
     end
     if str.length < 0x80
       return str.length.chr + str
     elsif str.length < 0x4000
       return Microtik::Utilities.bytepack(str.length | 0x8000, 2) + str
     elsif str.length < 0x200000
       return Microtik::Utilities.bytepack(str.length | 0xc00000, 3) + str
     elsif str.length < 0x10000000
       return Microtik::Utilities.bytepack(str.length | 0xe0000000, 4) + str
     elsif str.length < 0x0100000000
       return 0xf0.chr + Microtik::Utilities.bytepack(str.length, 5) + str
     else
       raise RuntimeError.new(
         "String is too long to be encoded for " +
         "the MikroTik API using a 4-byte length!"
       )
     end
   end

end
