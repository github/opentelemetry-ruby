# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentracing'

module OpenTelemetry
  module Compatibility
    module OpenTracing
      # A SpanContext for the OpenTelemetry/OpenTracing compatibility shim
      class SpanContext
        attr_reader :opentelemetry_context
        attr_reader :opentelemetry_span

        def initialize(opentelemetry_span)
          @opentelemetry_context = opentelemetry_span.context
        end

        def trace_id
          @opentelemetry_context.trace_id
        end

        def span_id
          @opentelemetry_context.span_id
        end

        def baggage
          OpenTelemetry.baggage.values(context: @opentelemetry_context)
        end
      end
    end
  end
end
