require 'thor'

module Pronto
  class CLI < Thor
    require 'pronto'
    require 'pronto/version'

    class << self
      def is_thor_reserved_word?(word, type)
        return false if word == 'run'
        super
      end
    end

    desc 'run [PATH]', 'Run Pronto'

    method_option :'exit-code',
                  type: :boolean,
                  desc: 'Exits with non-zero code if there were any warnings/errors.'

    method_option :commit,
                  type: :string,
                  aliases: '-c',
                  desc: 'Commit for the diff'

    method_option :unstaged,
                  type: :boolean,
                  aliases: ['-i', '--index'],
                  desc: 'Analyze changes made, but not in git staging area'

    method_option :staged,
                  type: :boolean,
                  desc: 'Analyze changes in git staging area'

    method_option :workdir,
                  type: :boolean,
                  aliases: ['-w'],
                  desc: 'Analyze both staged and unstaged changes'

    method_option :runner,
                  type: :array,
                  default: [],
                  aliases: '-r',
                  desc: 'Run only the passed runners'

    method_option :formatters,
                  type: :array,
                  default: ['text'],
                  aliases: ['formatter', '-f'],
                  desc: "Pick output formatters. Available: #{::Pronto::Formatter.names.join(', ')}"

    def run(path = '.')
      path = File.expand_path(path)

      gem_names = options[:runner].any? ? options[:runner] : ::Pronto::GemNames.new.to_a
      gem_names.each do |gem_name|
        require "pronto/#{gem_name}"
      end

      formatters = ::Pronto::Formatter.get(options[:formatters])

      commit_options = %i[workdir staged unstaged index]
      commit = commit_options.find { |o| options[o] } || options[:commit]

      repo_workdir = ::Rugged::Repository.discover(path).workdir
      relative     = path.sub(repo_workdir, '')

      messages = Dir.chdir(repo_workdir) do
        file = relative.length != path.length ? relative : nil
        ::Pronto.run(commit, '.', formatters, file)
      end
      if options[:'exit-code']
        error_messages_count = messages.count { |m| m.level != :info }
        exit(error_messages_count)
      end
    rescue Rugged::RepositoryError
      puts '"pronto" must be run from within a git repository or must be supplied the path to a git repository'
    rescue Pronto::Error => e
      $stderr.puts "Pronto errored: #{e.message}"
    end

    desc 'list', 'Lists pronto runners that are available to be used'

    def list
      puts ::Pronto::GemNames.new.to_a
    end

    desc 'version', 'Display version'
    map %w[-v --version] => :version

    def version
      puts Version::STRING
    end

    desc 'verbose-version', 'Display verbose version'
    map %w[-V --verbose-version] => :verbose_version

    def verbose_version
      puts Version.verbose
    end
  end
end
