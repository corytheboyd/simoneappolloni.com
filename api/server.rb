require_relative '../config/application'

require 'sinatra'
require 'rack/cors'

if development?
  require "sinatra/reloader"
end

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

get '/data' do
  content_type 'application/json'
  { foo: 'bar' }.to_json
end
