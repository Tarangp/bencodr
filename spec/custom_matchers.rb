RSpec::Matchers.define :bencode_to do |expected|
  match do |actual|
    @got = actual.bencode
    @got.should equal(expected)
  end
  
  failure_message_for_should do |actual|
    "expected that #{actual.inspect} would bencode to #{expected.inspect}, but got #{@got.inspect}}"
  end
end

RSpec::Matchers.define :bencode do |actual|
  chain :to do |_expected|
    @_expected = _expected
  end
  
  match do |klass|
    @got = klass.bencode(actual)
    @got.should == @_expected
  end
  
  failure_message_for_should do |klass|
    "expected #{klass.name} to bencode #{actual.inspect} to #{@_expected.inspect}, but got #{@got.inspect}"
  end
end

RSpec::Matchers.define :parse do |actual|
  chain :as do |type|
    @type = type
  end
  
  chain :to do |_expected|
    @_expected = _expected
  end
  
  match do |klass|
    scanner = StringScanner.new(actual)
    @got = klass.send(:"parse_#{@type}", scanner)
    @got.should == @_expected
  end
  
  failure_message_for_should do |klass|
    "expected #{klass.name} to bdencode #{actual.inspect} as #{@type} to #{@_expected.inspect}, but got #{@got.inspect}"
  end
end

RSpec::Matchers.define :generate_parse_error do |expected|
  chain :for do |type|
    @type = type
  end
  
  chain :with do |_actual|
    @_actual = _actual
  end
  
  match do |klass|
    scanner = StringScanner.new(@_actual)
    lambda do
      klass.send(:"parse_#{@type}", scanner)
    end.should raise_error(expected)
  end
  
  failure_message_for_should do |klass|
    "expected #{klass.name} to generate parse error #{expected.name} for #{@type} with #{actual}"
  end
end

RSpec::Matchers.define :bdecode_to do |expected|
  match do |actual|
    actual.bdecode.should == expected
  end
  
  failure_message_for_should do |actual|
    "expected that #{actual} would bdecode to #{expected}"
  end
end

RSpec::Matchers.define :bdecode do |actual|
  chain :to do |_expected|
    @_expected = _expected
  end
  
  match do |klass|
    klass.bdecode(actual).should == @_expected
  end
  
  failure_message_for_should do |actual|
    "expected that #{klass.name} would bdecode #{actual} to #{expected}"
  end
end