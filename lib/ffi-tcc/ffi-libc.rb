module LibC
  extend FFI::Library
  attach_function :malloc, [ :uint ], :pointer
  attach_function :free, [ :pointer ], :void
end
