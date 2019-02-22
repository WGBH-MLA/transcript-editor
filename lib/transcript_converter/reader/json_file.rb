require 'json'

module TranscriptConverter
  module Reader
    class JSONFile

      attr_accessor :file

      EXTENSIONS = [ '.json' ]

      def initialize(file)
        raise ArgumentError, "File parameter must be a File object" unless file.is_a?(File)
        @file = file
      end

      def run!
        puts "Reading file: #{File.basename(file.path)}"
        parse_json
      end

      private

      def parse_json
        if valid_json?(File.read(file))
          json = JSON.parse(File.read(file))

          raise "#{File.basename(file.path)}: JSON is not in the expected format." unless json.has_key?('parts')
          return { "file_name" => "#{File.basename(file.path, '.json')}", "parts" => json["parts"] }
        else
          nil
        end
      end

      def valid_json?(json)
        JSON.parse(json)
        true
      rescue JSON::ParserError => e
        false
      end
    end
  end
end
