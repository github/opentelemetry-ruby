#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

Bundler.require

# Export traces to console by default
ENV['OTEL_TRACES_EXPORTER'] ||= 'console'

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Redis'
end

redis_options = { host: ENV['REDIS_HOST'] || '127.0.0.1' }
redis_options[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD']

Redis.new(redis_options).set('mykey', 'hello world')
