# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Compatibility
    module OpenTracing
      # A ScopeManager for the OpenTelemetry/OpenTracing compatibility shim
      class ScopeManager
        KEY = :__opentelemetry_opentracing_scope__
        private_constant :KEY

        # Make a span instance active.
        #
        # @param span [Span] the Span that should become active
        # @param finish_on_close [Boolean] whether the Span should automatically be
        #   finished when Scope#close is called
        # @return [Scope] instance to control the end of the active period for the
        #  Span. It is a programming error to neglect to call Scope#close on the
        #  returned instance.
        def activate(span, finish_on_close: true)
          return if span.nil?

          OpenTelemetry::Context.current = OpenTelemetry::Trace.context_with_span(span.opentelemetry_span)
          self.active = Scope.new(self, span, finish_on_close)
          self.active
        end

        # @return [Scope] the currently active Scope which can be used to access the
        # currently active Span.
        #
        # If there is a non-null Scope, its wrapped Span becomes an implicit parent
        # (as Reference#CHILD_OF) of any newly-created Span at Tracer#start_active_span
        # or Tracer#start_span time.
        def active
          Thread.current[KEY]
        end

        private
        def active=(scope)
          Thread.current[KEY] = scope
        end
      end
    end
  end
end
