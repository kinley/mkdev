require 'csv'
require 'date'

class MovieCollection
  class FileNotFoundError < RuntimeError
  end

  attr_reader :genres

  KEYS = %i(link title year country date genres duration rating producer actors)

  def initialize(file_name)
    raise FileNotFoundError unless File.file?(file_name)
    @movies = parse_file(file_name)
    @genres = @movies.flat_map(&:genres).uniq
  end

  def all
    @movies
  end

  def sort_by(field)
    all.sort_by(&field)
  end

  def filter(facets)
    facets.reduce(all) do |res, (key, value)|
      res.select do |m|
        field = m.send(key)

        if field.is_a?(Array)
          field.grep(value).any?
        else
          value === field
        end
      end
    end
  end

  def stats(field)
    return unless %i(month year country producer actors genres).include?(field)
    all.flat_map(&field).each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
  end

  def print_stats(field)
    stats(field).sort.each do |field, count|
      puts "#{field}: #{count}"
    end
  end

  private

  def parse_file(file_name)
    CSV.foreach(file_name, col_sep: '|', headers: KEYS).map { |row| Movie.new(self, row) }
  end
end