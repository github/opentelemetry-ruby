# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Compatibility
    module OpenTracing
      # A Span for the OpenTelemetry/OpenTracing compatibility shim
      class Span
        attr_reader :context, :opentelemetry_span

        def initialize(opentelemetry_span)
          @opentelemetry_span = opentelemetry_span
          @context = SpanContext.new(@opentelemetry_span)
        end

        # Set the name of the operation
        #
        # @param [String] name
        def operation_name=(name)
          @opentelemetry_span.name = name
        end

        # Set a tag value on this span
        # @param key [String] the key of the tag
        # @param value [String, Numeric, Boolean] the value of the tag. If it's not
        # a String, Numeric, or Boolean it will be encoded with to_s
        def set_tag(key, value)
          if key == "error"
            mapped_value = case value
                           when true
                             OpenTelemetry::Trace::Status::ERROR
                           when false
                             OpenTelemetry::Trace::Status::OK
                           else
                             OpenTelemetry::Trace::Status::UNSET
                           end

            @opentelemetry_span.set_status(OpenTelemetry::Trace::Status.new(mapped_value))
          else
            mapped_value = if value.is_a?(Numeric) || value.is_a?(String) || value == true || value == false
                             value
                           else
                             value.to_s
                           end

            @opentelemetry_span.set_attribute(key, mapped_value)
          end
        end

        # Set a baggage item on the span
        # @param key [String] the key of the baggage item
        # @param value [String] the value of the baggage item
        def set_baggage_item(key, value)
          @opentelemetry_span.context = OpenTelemetry.baggage.set_value(key, value, context: @opentelemetry_span.context)
          @context = SpanContext.new(@opentelemetry_span)
        end

        # Get a baggage item
        # @param key [String] the key of the baggage item
        # @return [String] value of the baggage item
        def get_baggage_item(key)
          OpenTelemetry.baggage.value(key, context: @opentelemetry_span.context)
        end

        # @deprecated Use {#log_kv} instead.
        # Reason: event is an optional standard log field defined in spec and not required.  Also,
        # method name {#log_kv} is more consistent with other language implementations such as Python and Go.
        #
        # Add a log entry to this span
        # @param event [String] event name for the log
        # @param timestamp [Time] time of the log
        # @param fields [Hash{Symbol=>Object}] Additional information to log
        def log(event: nil, timestamp: Time.now, **fields)
          warn 'Span#log is deprecated.  Please use Span#log_kv instead.'

          fields = {} if fields.nil?
          unless event.nil?
            fields["event"] = event.to_s
          end

          log_kv(timestamp: timestamp, **fields)
        end

        # Add a log entry to this span
        # @param timestamp [Time] time of the log
        # @param fields [Hash{Symbol=>Object}] Additional information to log
        def log_kv(timestamp: Time.now, **fields)
          fields = {} if fields.nil?

          # TODO: If an explicit timestamp is specified, a conversion MUST be done to match the OpenTracing and OpenTelemetry units.

          if fields["event"] == "error" && fields["event.object"]
            fields.delete("event")
            @opentelemetry_span.record_exception(fields.delete("event.object"), fields)
          else
            name = fields.delete("event") || "log"

            if name == "error"
              name = "exception"

              fields["exception.type"] = fields.delete("error.kind") if fields["error.kind"]
              fields["exception.message"] = fields.delete("message") if fields["message"]
              fields["exception.stacktrace"] = fields.delete("stack") if fields["stack"]
            end

            @opentelemetry_span.add_event(name, fields)
          end
        end

        # Finish the {Span}
        # @param end_time [Time] custom end time, if not now
        def finish(end_time: Time.now)
          @opentelemetry_span.finish(end_timestamp: end_time)
        end
      end
    end
  end
end
