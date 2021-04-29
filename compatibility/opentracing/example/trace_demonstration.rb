# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'rubygems'
require 'bundler/setup'

Bundler.require

ENV['OTEL_TRACES_EXPORTER'] ||= 'console'
OpenTelemetry::SDK.configure

opentelemetry_tracer = OpenTelemetry.tracer_provider.tracer('opentracing_trace_demonstration', '0.17.0')
opentracing_shim = OpenTelemetry::Compatibility::OpenTracing::Tracer.new(tracer: opentelemetry_tracer)

top_scope = opentracing_shim.start_active_span('top_scope')
top_scope.span.set_tag('foo', 'top_scope')

middle_span = opentracing_shim.start_span('middle_scope')
opentracing_shim.scope_manager.activate(middle_span)
middle_scope = opentracing_shim.scope_manager.active
middle_scope.span.set_tag('foo', 'middle_scope')

opentracing_shim.start_active_span('bottom_scope') do |scope|
  scope.span.set_tag('foo', 'bottom_scope')
end

middle_scope.close
top_scope.close
