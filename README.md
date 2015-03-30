# Libmsh

msh (SACM コマンドラインツール) 用のライブラリ（にするかも）

## 使い方

事前にbundlerを入れておく。

### インタプリタで実行する場合

```
$ git clone https://github.com/seil-smf/libmsh.git
$ cd libmsh
$ bundle install --path vendor/bundle
$ bundle exec irb -Ilib  ## 下記サンプルコードコピペ
```

### 自前のRailsアプリ等に入れる場合

 * Gemfileに以下の行追加

```
gem 'libmsh', :git => 'https://github.com/seil-smf/libmsh.git'
```

 * インストール

```
$ bundle install --path vendor/bundle
```
後はサンプルのようなコードをコントローラ等によしなに組み込む


## 例
api_key等は適宜変更して下さい。

```ruby
require 'libmsh'

include Libmsh

conn_params = {
  :api_key => "******",
  :api_key_secret => "************",
  :url => "https://**.sacm.jp",
  :user_agent => "libmsh", # app_name
  :ssl_verify => false,
}

# /GET request sample
get_req_params = {
  :path => "/public-api/v1",
  :resource => "/home/search/sacode",
  :method => "GET",
  :user_code => "tsa********",
  :request_params => { :q => "tsw********"},
}

# /POST request sample
post_req_params = {
  :path => "/public-api/v1",
  :resource => "/user/:user_code/request/md-command",
  :content_type => "multipart/form-data",
  :method => "POST",
  :user_code => "tsa********",
  :request_params => [
                      {
                        :name => "code",
                        :param => "tsw********",
                      },
                      {
                        :name => "targetTime",
                        :param => "",
                      },
                      {
                        :name => "0/plain",
                        :param => "show system",
                      }
                     ]
}

# /PUT request sample
put_req_params = {
  :path => "/public-api/v1",
  :resource => "/user/:user_code/template/:id/pack/csv",
  :content_type => "multipart/form-data",
  :method => "PUT",
  :user_code => "tsa********",
  :id => "0",
  :request_params => {
    :name => "variable-csv-file",
    :filename => "sample.csv",
    :content_type => "text/csv",
  },
}


client = SACMClient.new(conn_params)

req = SACMRequest.new(get_req_params)
res = client.exec(req)
puts res

req = SACMRequest.new(post_req_params)
res = client.exec(req)
puts res

req = SACMRequest.new(put_req_params)
res = client.exec(req)
puts res
```

