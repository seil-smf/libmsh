# -*- coding: utf-8 -*-

require 'json'

require 'faraday'

module Libmsh
  class SACMClient
    def initialize(params)
      check_connection_params(params)

      @conn = Faraday.new(:url => params[:url], :ssl => { :verify => params[:ssl_verify] } ) do | faraday |
        #  faraday.response :logger
        faraday.request(:basic_auth, params[:api_key], params[:api_key_secret])
        faraday.adapter(:net_http)
      end

      @conn.headers[:user_agent] = params[:user_agent]

      @conn_multipart = Faraday.new(:url => params[:url], :ssl => { :verify => params[:ssl_verify] } ) do | faraday |
        #  faraday.response :logger
        faraday.request(:basic_auth, params[:api_key], params[:api_key_secret])
        faraday.request(:multipart)
        faraday.request(:url_encoded)
        faraday.adapter(:net_http)
      end

      @conn_multipart.headers[:user_agent] = params[:user_agent]
    end

    def check_connection_params(params)
      raise "':api_key' is invalid." unless String === params[:api_key]
      raise "':api_key_secret' is invalid." unless String === params[:api_key_secret]
      params[:user_agent] = "libmsh" if params[:user_agent].nil?
      raise "':ssl_verify' is invalid." unless !!params[:ssl_verify] == params[:ssl_verify]
    end

    def replace_resource_path(params)
      resource = params[:resource].split("/").map do |token|
        if /^:/ =~ token
          sym_token = token.slice(1..-1).to_sym
          raise "'#{token}' is required to run #{params[:resource]} API."if params[sym_token].nil?
          params[sym_token]
        else
          token
        end
      end

      resource.join("/")
    end

    def exec(params)
      params[:resource] = replace_resource_path(params) unless params[:resource].nil?
      if params[:content_type] =="multipart/form-data"
        build_multipart params
      end

      case params[:method]
      when "GET"
        res = self.get(params)
      when "POST"
        res = self.post(params)
      when "PUT"
        res = self.put(params)
      when "DELETE"
        res = self.delete(params)
      end

      res
    end

    def get(params)
      res = @conn.get do |req|
        req.url("#{params[:path]}/#{params[:resource]}", params[:request_params])
        req.headers['content-type'] = params[:content_type] unless params[:content_type].nil?
      end
    end

    def post(params)
      if params[:payload].nil?
        res = @conn.post do |req|
          req.url("#{params[:path]}/#{params[:resource]}")
          req.headers['content-type'] = params[:content_type] unless params[:content_type].nil?
          if params[:content_type] =~ /^multipart\/form-data/
            req.body = params[:body]
          elsif params[:content_type] =~ /^application\/json/
            req.body = JSON.generate(params[:request_params])
          else
            req.body = params[:request_params]
          end
        end
      else
        res = @conn_multipart.post("#{params[:path]}/#{params[:resource]}", params[:payload])
      end
    end

    def put(params)
      if params[:payload].nil?
        res = @conn.put do |req|
          req.url("#{params[:path]}/#{params[:resource]}")
          req.headers['content-type'] = params[:content_type] unless params[:content_type].nil?
          if params[:content_type] =~ /^multipart\/form-data/
            req.body = params[:body]
          elsif params[:content_type] =~ /^application\/json/
            req.body = JSON.generate(params[:request_params])
          else
            req.body = params[:request_params]
          end
        end
      else
        res = @conn_multipart.put("#{params[:path]}/#{params[:resource]}", params[:payload])
      end

    end

    def delete(params)
      res = @conn.delete do |req|
        req.url("#{params[:path]}/#{params[:resource]}")
      end
    end

    def build_multipart(params)
      if Array === params[:request_params]
        multipart = MultipartFormData.new
        multipart.set_content_type(params[:content_type])
        params[:request_params].each do | param |
          multipart.set_boundary
          multipart.set_crlf
          multipart.set_form_data('Content-Disposition: form-data; name="' + param[:name] +'"')
          multipart.set_crlf
          multipart.set_form_data(param[:param] || "")
        end
        multipart.set_boundary
        multipart.set_str("--")

        params[:content_type] = multipart[:content_type]
        params[:body] = multipart[:body]
      elsif params[:request_params][:filename]
        multipart = Faraday::Request::Multipart.new
        payload = { }

        payload[params[:request_params][:name].to_sym] = Faraday::UploadIO.new(params[:request_params][:filename], params[:request_params][:content_type])
        params[:payload] = payload
      end

      multipart
    end

  end
end

