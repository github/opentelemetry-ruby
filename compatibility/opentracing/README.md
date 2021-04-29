# OpenTelemetry/OpenTracing Compatibility Shim

This directory contains a reference implementation of the OpenTelemetry/OpenTracing
compatibility shim. This allows you to gradually migrate an application (which has been
instrumented with OpenTracing) to OpenTelemetry instrumentation in gradual steps. The shim
implements the OpenTracing API, but delegates all operations to the underlying OpenTelemetry API.

## How do I get started?

Install the gem using:

```
gem install opentelemetry-compatibility-opentracing
```

Or, if you use [bundler][bundler-home], include `opentelemetry-compatibility-opentracing` in your `Gemfile`.

## Usage

To use the compatibility shim, configure it in your application.

```ruby
require 'opentelemetry/sdk'
require 'opentelemetry/compatibility/opentracing'

# Configure the SDK as normal
OpenTelemetry::SDK.configure

# Get an OpenTelemetry tracer that will be used to actually record spans:
opentelemetry_tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

# Retrieve an OpenTracing shim which delegates span operations to the underlying OpenTelemetry tracer.
opentracing_shim = OpenTelemetry::Compatibility::OpenTracing::Tracer.new(tracer: opentelemetry_tracer)
```

Then, replace all references to your OpenTracing tracer with the OpenTracing shim that was just configured:

```diff
TODO: make a diff
```

## Examples

Example usage can be seen in the `./example/trace_demonstration.rb` file [here](https://github.com/open-telemetry/opentelemetry-ruby/blob/main/compatibility/opentracing/example/trace_demonstration.rb)

## How can I get involved?

The `opentelemetry-compatibility-opentracing` gem source is [on github][repo-github], along with related gems including `opentelemetry-api` and `opentelemetry-sdk`.

The OpenTelemetry Ruby gems are maintained by the OpenTelemetry-Ruby special interest group (SIG). You can get involved by joining us in [GitHub Discussions][discussions-url] or attending our weekly meeting. See the [meeting calendar][community-meetings] for dates and times. For more information on this and other language SIGs, see the OpenTelemetry [community page][ruby-sig].

## License

The `opentelemetry-compatibility-opentracing` gem is distributed under the Apache 2.0 license. See [LICENSE][license-github] for more information.

[bundler-home]: https://bundler.io
[repo-github]: https://github.com/open-telemetry/opentelemetry-ruby
[license-github]: https://github.com/open-telemetry/opentelemetry-ruby/blob/main/LICENSE
[ruby-sig]: https://github.com/open-telemetry/community#ruby-sig
[community-meetings]: https://github.com/open-telemetry/community#community-meetings
[discussions-url]: https://github.com/open-telemetry/opentelemetry-ruby/discussions
