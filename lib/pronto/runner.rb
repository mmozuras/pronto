module Pronto
  class Runner
    include Plugin

    def initialize(patches, commit = nil)
      @patches = patches
      @commit = commit
      @config = Config.new
    end

    def self.runners
      repository
    end

    def self.title
      @runner_name ||= begin
        source_path, _line = instance_method(:run).source_location
        file_name, _extension = File.basename(source_path).split('.')
        file_name
      end
    end

    def ruby_patches
      return [] unless @patches

      @ruby_patches ||= @patches.select { |patch| patch.additions > 0 }
        .select { |patch| ruby_file?(patch.new_file_full_path) }
    end

    def ruby_file?(path)
      rb_file?(path) ||
        rake_file?(path) ||
        gem_file?(path) ||
        ruby_executable?(path)
    end

    def repo_path
      @patches.first.repo.path
    end

    private

    def rb_file?(path)
      File.extname(path) == '.rb'
    end

    def rake_file?(path)
      File.extname(path) == '.rake'
    end

    def gem_file?(path)
      File.basename(path) == 'Gemfile' || File.extname(path) == '.gemspec'
    end

    def ruby_executable?(path)
      return false unless File.file?(path)
      line = File.open(path, &:readline)
      line =~ /#!.*ruby/
    rescue ArgumentError, EOFError
      false
    end
  end
end
