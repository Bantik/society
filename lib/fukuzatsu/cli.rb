require 'thor'
require 'fukuzatsu'

module Fukuzatsu

  class CLI < Thor

    desc "parse PATH_TO_FILE --format", "Parse a file."
    def parse(file, format='text')
      file = ParsedFile.new(path_to_file: file)
      case format
      when 'html'
        Formatters::Html.new(file).export
      when 'csv'
        Formatters::Csv.new(file).export
      else
        Formatters::Text.new(file).export
      end
    end

  end

end