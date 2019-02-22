module TranscriptConverter
  module Converter
    class WebVTTFile

      attr_accessor :content, :directory

      EXTENSIONS = [ 'vtt', 'webvtt', '.vtt' ]
      CONTENT_HEADER = "WEBVTT"

      def initialize(content, directory)
        @content = content
        @directory = directory
      end

      def run!
        puts "Converting file: #{content['file_name']}.json" 
        create_file
      end

      private

      def create_file
        puts "Writing #{content['file_name']}.vtt to #{directory}"
        open(directory + "#{content['file_name']}.vtt", 'w') do |file|
          file << TranscriptConverter::Converter::WebVTTFile::CONTENT_HEADER
          file << "\n\n"
          file << reformatted_content
          file
        end
      end

      def reformatted_content
        @reformatted_content ||= content["parts"].map do |chunk|
          start_time = convert_seconds(chunk["start_time"])
          end_time = convert_seconds(chunk["end_time"])
          text = chunk["text"]
          "#{start_time} --> #{end_time}\n#{text}\n\n"
        end.join('')
      end

      def convert_seconds(seconds)
        Time.at(seconds.to_f).utc.strftime("%T.%L")
      end

    end
  end
end
