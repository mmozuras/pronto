module Pronto
  class ConfigFile
    DEFAULT_MESSAGE_FORMAT = '%{msg}'.freeze

    EMPTY = {
      'all' => {
        'exclude' => [],
        'include' => []
      },
      'github' => {
        'slug' => nil,
        'access_token' => nil,
        'api_endpoint' => 'https://api.github.com/',
        'web_endpoint' => 'https://github.com/'
      },
      'gitlab' => {
        'slug' => nil,
        'api_private_token' => nil,
        'api_endpoint' => 'https://gitlab.com/api/v4'
      },
      'bitbucket' => {
        'slug' => nil,
        'key' => nil,
        'secret' => nil,
        'api_endpoint' => nil,
        'auto_approve' => false,
        'web_endpoint' => 'https://bitbucket.org/'
      },
      'bitbucket_server' => {
        'slug' => nil,
        'username' => nil,
        'password' => nil,
        'api_endpoint' => nil,
        'auto_approve' => false,
        'web_endpoint' => 'https://bitbucket.org/'
      },
      'text' => {
        'format' => '%{color_location} %{color_level}: %{msg}'
      },
      'runners' => [],
      'formatters' => [],
      'max_warnings' => nil,
      'verbose' => false,
      'format' => DEFAULT_MESSAGE_FORMAT
    }.freeze

    def initialize(path = '.pronto.yml')
      @path = path
    end

    def to_h
      hash = File.exist?(@path) ? YAML.load_file(@path) : {}
      deep_merge(hash)
    end

    private

    def deep_merge(hash)
      merger = proc do |_, oldval, newval|
        if oldval.is_a?(Hash) && newval.is_a?(Hash)
          oldval.merge(newval, &merger)
        else
          oldval.nil? ? newval : oldval
        end
      end

      hash.merge(EMPTY, &merger)
    end
  end
end
