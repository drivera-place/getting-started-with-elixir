# Protocols

**AVL Protocol decoders project**

This project contains various AVL Protocol decoders for different GPS tracking devices and vendors.

## Contents
  - [Development guide](./README.md#development-guide)
  - [Test guide](./README.md#test-guide)
  - [Contributing](./README.md#contributing)
  - [Elixir breadcrumbs](./README.md#elixir-breadcrumbs)
    - [Pattern matching and deconstruction](./README.md#1-pattern-matching-and-deconstruction)
    - [Use pattern matching and `with` statements](./README.md#2-use-pattern-matching-and-with-statements)
    - [Use binary pattern matching for deconstruction](./README.md#3-use-binary-pattern-matching-for-deconstruction)

## Development guide

Before starting, please follow the [Setup Guide for Elixir environment](../SETUP.md) to set up your Elixir environment.

To start working on the project, please navigate to the `./lib/protocols`, this directory should contain a subdirectory for each `vendor/codec/transport_protocol` implementation, for instance `./lib/protocols/teltonika/codec8/` contains the Teltonika "vendor" and its protocol codecs implementations according codec and transport protocol.

Each protocol implementation should contain the following files:
- `README.md`: A markdown file containing the protocol description, links to official documentation, and any other relevant information (optional).
- `codec.ex`: The main codec implementation file, which should define the codec module and its functions.
- `transport_protocol.ex`: The transport protocol implementation file, which should define the transport protocol module and its functions.
- `test/`: A directory containing test files for the codec and transport protocol implementations, following the same structure as the main implementation files, e.g., `~/test/vendor/codec/` and as many test files as required, always taking care not to have giant test files, **_we really don't need test files of 200+ lines!_** if we can separate them by functionality or by protocol operation we may handle best the code.

## Test guide

Try to cover as many cases as possible, including edge cases and error handling. Use descriptive names for your test cases to make it clear what each test is verifying.

Tests should be readalble and maintainable. Avoid complex logic in test cases; if necessary, extract common setup code into helper functions or helper submodules for the test, use other directives like `setup_all` or `async: true`.

In general the structure of a test should be as follows:

```elixir
defmodule Protocols.Vendor.ProtocolCodecTest do
  use ExUnit.Case

    # Setup code (if needed)

  test "description of the test case" do
    # Arrange comment mandatory.
    # Your setup code here.

    # Act comment mandatory.
    # The code that performs the action being tested.

    # Assert comment mandatory.
    # Your assertions here.
  end
end
```

Engineering team encorages you to do and practice TDD (Test Driven Development) as much as possible, this will help you to write better code and to find bugs early in the development process.

## Contributing

New features, bug fixes, and implementation should follow the guidelines described in this document. Please ensure that your code adheres to the project's coding standards and includes appropriate tests (mandatory).

When posible, define integration tests and some kind of validation againts phisical devices or official simulators, do not asume that the protocol documentation is correct, always try to validate it with real world data or real world.

When submitting a pull request, please provide a clear description of the changes made and the reasons behind them. This will help reviewers understand the context and purpose of your contribution.

## Elixir breadcrumbs

#### 1. Pattern matching and deconstruction

Define structures for deconstruction of the protocol messages, this will help to understand the protocol and to write better code:

```elixir
defmodule Protocols.Vendor.ProtocolCodec.Message do
  defstruct [
    :field1,
    :field2,
    :field3,
    # Add more fields as needed
  ]
end
```

#### 2. Use pattern matching and `with` statements

Use pattern matching to extract data from binary messages, this will help to write more readable and maintainable code:

```elixir
defmodule Protocols.Vendor.ProtocolCodec do
  def decode(<<field1::size(8), field2::size(16), field3::size(32), _rest::binary>>) do
    %Protocols.Vendor.ProtocolCodec.Message{
      field1: field1,
      field2: field2,
      field3: field3
    }
  end
end
```

Use `with` statements to handle complex decoding logic, this will help to write more readable and maintainable code:

```elixir
defmodule Protocols.Vendor.ProtocolCodec do
  def decode(message) do
    with {:ok, header} <- decode_header(message),
         {:ok, body} <- decode_body(header, message),
         {:ok, footer} <- decode_footer(body, message) do
      {:ok, %Protocols.Vendor.ProtocolCodec.Message{header: header, body: body, footer: footer}}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
```

#### 3. Use binary pattern matching for deconstruction

Deconstruction binaries using pattern matching, this will help to write more readable and maintainable code:

```elixir
def parse(<<message::binary>>) do
    
    Logger.debug("Report message: #{Base.encode16(message)}")

    <<
      # 4 bytes for preamble, ignored or not used.
      _preamble::binary-size(4),
      # 4 bytes for data field length
      data_field_length::binary-size(4),
      # 1 byte for codec ID
      codec_id::binary-size(1),
      # 1 byte for number of data 1
      number_of_data1::binary-size(1),
      # The rest is AVL data
      rest::binary
    >> = message

    <<
      # Timestamp
      timestamp::unsigned-integer-size(64),
      # Priority
      priority::unsigned-integer-size(8),
      # Latitude
      lat::signed-integer-size(32),
      # Longitude
      lon::signed-integer-size(32),
      # Altitude
      alt::unsigned-integer-size(16),
      _rest::binary
    >> = rest

    report = %Teltonika.Gps{
      timestamp: timestamp,
      priority: priority,
      latitude: lat / 10_000_000,
      longitude: lon / 10_000_000,
      altitude: alt
    }

    # Continue parsing based on codec_id and so on...
end
```