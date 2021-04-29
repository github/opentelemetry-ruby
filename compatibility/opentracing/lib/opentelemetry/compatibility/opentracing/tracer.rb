# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentracing'

module OpenTelemetry
  module Compatibility
    module OpenTracing
      # The OpenTelemetry/OpenTracing compatibility shim
      class Tracer
        attr_reader :propagation, :scope_manager

        def initialize(tracer:, propagation: OpenTelemetry.propagation)
          @opentelemetry_tracer = tracer
          @scope_manager = OpenTelemetry::Compatibility::OpenTracing::ScopeManager.new
          @propagation = propagation
        end

        # @return [Span, nil] the active span. This is a shorthand for
        #   `scope_manager.active.span`, and nil will be returned if
        #   Scope#active is nil.
        def active_span
          scope = scope_manager.active
          scope.span if scope
        end

        # Returns a newly started and activated Scope.
        #
        # If the Tracer's ScopeManager#active is not nil, no explicit references
        # are provided, and `ignore_active_scope` is false, then an inferred
        # References#CHILD_OF reference is created to the ScopeManager#active's
        # SpanContext when start_active is invoked.
        #
        # @param operation_name [String] The operation name for the Span
        # @param child_of [SpanContext, Span] SpanContext that acts as a parent to
        #        the newly-started Span. If a Span instance is provided, its
        #        context is automatically substituted. See [Reference] for more
        #        information.
        #
        #   If specified, the `references` parameter must be omitted.
        # @param references [Array<Reference>] An array of reference
        #   objects that identify one or more parent SpanContexts.
        # @param start_time [Time] When the Span started, if not now
        # @param tags [Hash] Tags to assign to the Span at start time
        # @param ignore_active_scope [Boolean] whether to create an implicit
        #   References#CHILD_OF reference to the ScopeManager#active.
        # @param finish_on_close [Boolean] whether span should automatically be
        #   finished when Scope#close is called
        # @yield [Scope] If an optional block is passed to start_active_span it will
        #   yield the newly-started Scope. If `finish_on_close` is true then the
        #   Span will be finished automatically after the block is executed.
        # @return [Scope, Object] If passed an optional block, start_active_span
        #   returns the block's return value, otherwise it returns the newly-started
        #   and activated Scope
        def start_active_span(operation_name,
                              child_of: nil,
                              references: nil,
                              start_time: Time.now,
                              tags: nil,
                              ignore_active_scope: false,
                              finish_on_close: true)

          span = start_span(operation_name,
                            child_of: child_of,
                            references: references,
                            start_time: start_time,
                            tags: tags,
                            ignore_active_scope: ignore_active_scope)

          scope_manager.activate(span, finish_on_close: finish_on_close).tap do |scope|
            if block_given?
              begin
                return yield scope
              ensure
                scope.close
              end
            end
          end
        end

        # Like #start_active_span, but the returned Span has not been registered via the
        # ScopeManager.
        #
        # @param operation_name [String] The operation name for the Span
        # @param child_of [SpanContext, Span] SpanContext that acts as a parent to
        #        the newly-started Span. If a Span instance is provided, its
        #        context is automatically substituted. See [Reference] for more
        #        information.
        #
        #   If specified, the `references` parameter must be omitted.
        # @param references [Array<Reference>] An array of reference
        #   objects that identify one or more parent SpanContexts.
        # @param start_time [Time] When the Span started, if not now
        # @param tags [Hash] Tags to assign to the Span at start time
        # @param ignore_active_scope [Boolean] whether to create an implicit
        #   References#CHILD_OF reference to the ScopeManager#active.
        # @yield [Span] If passed an optional block, start_span will yield the
        #   newly-created span to the block. The span will be finished automatically
        #   after the block is executed.
        # @return [Span, Object] If passed an optional block, start_span will return
        #  the block's return value, otherwise it returns the newly-started Span
        #  instance, which has not been automatically registered via the
        #  ScopeManager
        def start_span(operation_name,
                       child_of: nil,
                       references: nil,
                       start_time: Time.now,
                       tags: nil,
                       ignore_active_scope: false)

          if child_of.nil? && references.nil? && !ignore_active_scope && active_span
            child_of = OpenTelemetry::Trace.context_with_span(active_span.opentelemetry_span)
          end

          if references
            links = references.map { |r| OpenTelemetry::Trace::Link.new(r) } # TODO This is absolutely wrong
          end

          # TODO convert start_time
          # TODO unwrap child_of into a context better maybe?

          span = @opentelemetry_tracer.start_span(operation_name,
                                                  with_parent: child_of,
                                                  attributes: tags,
                                                  links: links,
                                                  start_timestamp: start_time)


          Span.new(span).tap do |s|
            if block_given?
              begin
                return yield s
              ensure
                s.finish
              end
            end
          end
        end

        # Inject a SpanContext into the given carrier
        #
        # @param span_context [SpanContext]
        # @param format [OpenTracing::FORMAT_TEXT_MAP, OpenTracing::FORMAT_BINARY, OpenTracing::FORMAT_RACK]
        # @param carrier [Carrier] A carrier object of the type dictated by the specified `format`
        #
        # @todo FORMAT_BINARY
        def inject(span_context, format, carrier)
          case format
          when OpenTracing::FORMAT_TEXT_MAP, OpenTracing::FORMAT_BINARY, OpenTracing::FORMAT_RACK
            @propagation.inject(carrier, span_context)
          else
            warn 'Unknown inject format'
          end
        end

        # Extract a SpanContext in the given format from the given carrier.
        #
        # @param format [OpenTracing::FORMAT_TEXT_MAP, OpenTracing::FORMAT_BINARY, OpenTracing::FORMAT_RACK]
        # @param carrier [Carrier] A carrier object of the type dictated by the specified `format`
        # @return [SpanContext, nil] the extracted SpanContext or nil if none could be found
        def extract(format, carrier)
          case format
          when OpenTracing::FORMAT_TEXT_MAP, OpenTracing::FORMAT_BINARY, OpenTracing::FORMAT_RACK
            @propagation.extract(carrier)
          else
            warn 'Unknown extract format'
            nil
          end
        end
      end
    end
  end
end
