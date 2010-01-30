# encoding: UTF-8

require 'strscan'

module BEncode
  module Parser
    class << self
      def parse_object(scanner)
        case scanner.peek(1)[0]
          when ?0..?9
            parse_string(scanner)
          when ?i
            parse_integer(scanner)
          when ?l
            parse_list(scanner)
          when ?d
            parse_dictionary(scanner)
          else
            nil
        end
      end

      def parse_string(scanner)
        length = scanner.scan(/[1-9][0-9]*|0/)    or raise BEncodeError, "Invalid string: length invalid. #{scanner.pos}"
        scanner.scan(/:/)                         or raise BEncodeError, "Invalid string: missing colon(:). #{scanner.pos}"
        scanner.scan(/.{#{length.to_i}}/)         or raise BEncodeError, "Invalid string: length too long(#{length}) #{scanner.pos}."
      end

      def parse_integer(scanner)
        scanner.scan(/i/)                         or raise BEncodeError, "Invalid integer: missing opening i. #{scanner.pos}"
        integer = scanner.scan(/-?[1-9][0-9]*|0/) or raise BEncodeError, "Invalid integer: valid integer not found. #{scanner.pos}"
        scanner.scan(/e/)                         or raise BEncodeError, "Invalid integer: missing closing e. #{scanner.pos}"
        integer.to_i
      end

      def parse_list(scanner)
        list = []

        scanner.scan(/l/) or raise BEncodeError, "Invalid list: missing opening l. #{scanner.pos}"
        while true
          object = parse_object(scanner)
          break unless object
          list << object
        end
        scanner.scan(/e/) or raise BEncodeError, "Invalid list: missing closing e. #{scanner.pos}"

        list
      end

      def parse_dictionary(scanner)
        dictionary = {}

        scanner.scan(/d/) or raise BEncodeError, "Invalid dictionary: missing opening d. #{scanner.pos}"
        while true
          key_value = parse_key_value(scanner)
          break unless key_value
          dictionary.store(*key_value)
        end
        scanner.scan(/e/) or raise BEncodeError, "Invalid dictionary: missing closing e. #{scanner.pos}"

        dictionary
      end

      def parse_key_value(scanner)
        key = parse_object(scanner)
        return key unless key
        raise BEncodeError, "Invalid dictionary: key is not a string. #{scanner.pos}" unless key.is_a?(::String)

        value = parse_object(scanner)
        raise BEncodeError, "Invalid dictionary: missing value for key (#{key}). #{scanner.pos}" unless value

        [key, value]
      end
      private :parse_key_value
    end
  end
end