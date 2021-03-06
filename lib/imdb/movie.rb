require 'date'

module IMDB
  class Movie
    GenreNotFoundError = Class.new(RuntimeError)

    attr_accessor :country, :date, :month, :year, :duration, :link, :producer, :rating, :title,
                  :actors, :genres
    attr_reader :collection

    def initialize(collection = nil, params)
      @collection = collection
      params.each { |k, v| send("#{k}=", v) }
    end

    def self.build(collection = nil, params)
      params = prepare_data(params)
      case params[:year]
      when 1900...1945
        IMDB::AncientMovie.new(collection, params)
      when 1945...1968
        IMDB::ClassicMovie.new(collection, params)
      when 1968...2000
        IMDB::ModernMovie.new(collection, params)
      when 2000..Date.today.year
        IMDB::NewMovie.new(collection, params)
      else
        Movie.new(collection, params)
      end
    end

    def period
      self.class.name.split('::').last.gsub('Movie', '').downcase.to_sym
    end

    def has_genre?(genre)
      raise GenreNotFoundError if @collection && !@collection.genres.include?(genre)
      genres.include?(genre)
    end

    def fit?(key, value)
      field = send(key)

      if field.is_a?(Array)
        if value.is_a?(Array)
          (field & value).any?
        else
          field.any? { |i| value === i }
        end
      else
        value === field
      end
    end

    def to_s
      "#{title} (#{country}; #{date}; #{genres.join('/')}) - #{duration} min"
    end

    def inspect
      "#{title} | #{country} | #{year} | #{producer} | #{genres} | #{actors}"
    end

    private

    def self.prepare_data(params)
      params.to_h.merge({
        year: params[:year].to_i,
        duration: params[:duration].to_i,
        rating: params[:rating].to_f,
        genres: params[:genres].split(','),
        actors: params[:actors].split(','),
        month: get_month(params[:date]),
        date: parse_date(params[:date])
      })
    end

    def self.parse_date(str)
      (2 - str.count('-')).times { str << '-01' }
      Date.parse(str)
    end

    def self.get_month(str)
      str.split('-')[1]&.to_i || 0
    end
  end
end
