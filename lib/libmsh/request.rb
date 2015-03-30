# -*- coding: utf-8 -*-

module Libmsh
  class SACMRequest < Hash
    def initialize(params = nil)
      self.merge!(params) if Hash === params
    end

    def validate
      # バリデータ的なものを
    end
  end
end
