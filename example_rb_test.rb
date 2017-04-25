require 'test/unit'
require_relative 'example_pb'

class ExampleTest < Test::Unit::TestCase
  # FAILS: Google::Protobuf::ParseError: Error occurred during parsing: String specified for non-string/non-enum field: created_at
  # even though PB JSON Mapping spec defines:
  # Timestamp	string	"1972-01-01T10:00:20.021Z"	Uses RFC 3339, where generated output will always be Z-normalized and uses 0, 3, 6 or 9 fractional digits.
  def test_timestamped_conforming
    parsed = Timestamped.decode_json('{"created_at": "2017-04-21T20:22:04.663955830Z"}')
    assert_equal(Google::Protobuf::Timestamp.new(seconds: 1492806124, nanos: 663955830), parsed.created_at)
  end

  # PASSES
  # Probably should not pass because does not say this format is allowed, but does match underlying form
  def test_timestamped_nonconforming
    parsed = Timestamped.decode_json('{"created_at": {"seconds":1492806124,"nanos":663955830}}')
    assert_equal(Google::Protobuf::Timestamp.new(seconds: 1492806124, nanos: 663955830), parsed.created_at)
  end

  # FAILS: Google::Protobuf::ParseError: Error occurred during parsing: String specified for non-string/non-enum field: seq
  # even though PB JSON Mapping spec defines:
  # int64, fixed64, uint64	string	"1", "-10"	JSON value will be a decimal string. Either numbers or strings are accepted.
  def test_sequential_conforming
    parsed = Sequential.decode_json('{"seq": "1"}')
    assert_equal(1, parsed.seq)
  end

  # PASSES
  # Allows since spec says "Either numbers or strings are accepted"
  def test_sequential_nonconforming
    parsed = Sequential.decode_json('{"seq": 1}')
    assert_equal(1, parsed.seq)  end
end
