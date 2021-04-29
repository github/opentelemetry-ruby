# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Compatibility
    module OpenTracing
      # A Scope for the OpenTelemetry/OpenTracing compatibility shim
      class Scope
        attr_reader :span

        def initialize(manager, span, finish_on_close)
          @manager = manager
          @parent = manager.active&.span
          @span = span
          @finish_on_close = finish_on_close
        end

        def close
          @span.finish if @finish_on_close
          @manager.activate(@parent)
        end
      end
    end
  end
end
