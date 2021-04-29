# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry'

module OpenTelemetry
  module Compatibility
    # Contains the OpenTelemetry/OpenTracing compatibility layer
    module OpenTracing
    end
  end
end

require_relative './opentracing/tracer'
require_relative './opentracing/span'
require_relative './opentracing/span_context'
require_relative './opentracing/scope_manager'
require_relative './opentracing/scope'
require_relative './opentracing/version'
