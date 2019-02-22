require 'transcript_converter/transcript_files'
require 'transcript_converter/reader'
require 'transcript_converter/converter'

module TranscriptConverter
  class Runner

    attr_reader :transcript_files, :to_format, :directory

    def initialize(transcript_files_path, directory, to_format)
      raise "Directory doesn't exist at #{Rails.root + directory}" unless Dir.exist?(Rails.root + directory)
      @directory ||= Rails.root + directory
      @to_format ||= to_format
      @transcript_files = TranscriptConverter::TranscriptFiles.new(transcript_files_path).files
    end

    def run!
      converters.each do |converter|
        converter.run!
      end
    end

    private

    def readers
      @readers ||= transcript_files.map do |file|
        next unless File.exist?(file.path)
        TranscriptConverter::Reader.factory(File.extname(File.basename(file.path)), file)
      end
    end

    def converters
      @converters ||= readers.map do |reader|
        TranscriptConverter::Converter.factory(to_format, reader.run!, directory)
      end
    end

  end
end
