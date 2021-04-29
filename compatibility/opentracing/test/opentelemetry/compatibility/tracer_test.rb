# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

require_relative '../../../lib/opentelemetry/compatibility/opentracing'

describe OpenTelemetry::Compatibility::OpenTracing::Tracer do
  let(:tracer) { OpenTelemetry.tracer_provider.tracer }
  let(:shim) { OpenTelemetry::Compatibility::OpenTracing::Tracer.new(tracer: tracer) }

  it 'uses the global propagation when none is configured' do
    _(shim.propagation).must_be_instance_of OpenTelemetry::Context::Propagation::CompositePropagator
  end
  # it 'has #name' do
  #   _(shim.name).must_equal 'OpenTelemetry::Compatibility::OpenTracing'
  # end
  #
  # it 'has #version' do
  #   _(shim.version).wont_be_nil
  #   _(shim.version).wont_be_empty
  # end

  # describe '#install' do
  #   it 'accepts argument' do
  #     _(instrumentation.install({})).must_equal(true)
  #     instrumentation.instance_variable_set(:@installed, false)
  #   end
  # end
end
