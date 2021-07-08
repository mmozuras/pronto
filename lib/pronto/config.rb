module Pronto
  class Config
    def initialize(config_hash = ConfigFile.new.to_h)
      @config_hash = config_hash
    end

    %w[github gitlab bitbucket].each do |service|
      ConfigFile::EMPTY[service].each do |key, _|
        name = "#{service}_#{key}"
        define_method(name) { ENV["PRONTO_#{name.upcase}"] || @config_hash[service][key] }
      end
    end

    def default_commit
      default_commit =
        ENV['PRONTO_DEFAULT_COMMIT'] ||
        @config_hash.fetch('default_commit', 'master')
      default_commit
    end

    def consolidate_comments?
      consolidated =
        ENV['PRONTO_CONSOLIDATE_COMMENTS'] ||
        @config_hash.fetch('consolidate_comments', false)
      consolidated
    end

    def github_review_type
      review_type =
        ENV['PRONTO_GITHUB_REVIEW_TYPE'] ||
        @config_hash.fetch('github_review_type', false)

      if review_type == 'request_changes'
        'REQUEST_CHANGES'
      else
        'COMMENT'
      end
    end

    def excluded_files(runner)
      files =
        if runner == 'all'
          ENV['PRONTO_EXCLUDE'] || @config_hash['all']['exclude']
        else
          @config_hash.fetch(runner, {})['exclude']
        end

      Array(files)
        .flat_map { |path| Dir[path.to_s] }
        .map { |path| File.expand_path(path) }
    end

    def github_hostname
      URI.parse(github_web_endpoint).host
    end

    def bitbucket_hostname
      URI.parse(bitbucket_web_endpoint).host
    end

    def warnings_per_review
      ENV['PRONTO_WARNINGS_PER_REVIEW'] && Integer(ENV['PRONTO_WARNINGS_PER_REVIEW']) || @config_hash['warnings_per_review']
    end

    def max_warnings
      ENV['PRONTO_MAX_WARNINGS'] && Integer(ENV['PRONTO_MAX_WARNINGS']) || @config_hash['max_warnings']
    end

    def message_format(formatter)
      formatter_config = @config_hash[formatter]
      if formatter_config && formatter_config.key?('format')
        formatter_config['format']
      else
        ENV['PRONTO_FORMAT'] || @config_hash['format']
      end
    end

    def logger
      @logger ||= begin
        verbose = ENV['PRONTO_VERBOSE'] || @config_hash['verbose']
        verbose ? Logger.new($stdout) : Logger.silent
      end
    end
  end
end
