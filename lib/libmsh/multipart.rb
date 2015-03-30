module Libmsh
  class MultipartFormData < Hash
    CRLF = "\r\n"
    BOUNDARY_CHAR = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

    def initialize
      @boundary = build_boundary(64)
      self[:body] = ""
      self[:content_type] = ""
    end

    def set_boundary
      self[:body] << "--" + @boundary
    end

    def set_content_type(content_type)
      self[:content_type] << content_type + "; boundary=" + @boundary
    end

    def set_form_data(form_data)
      self[:body] << form_data + CRLF
    end

    def set_crlf
      self[:body] << CRLF
    end

    def set_str(str)
      self[:body] << str
    end

    private

    def build_boundary(n)
      boundary = ''
      n.times do
        boundary << BOUNDARY_CHAR[Random.rand(62)]
      end
      return boundary
    end
  end
end
