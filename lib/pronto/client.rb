module Pronto
  class Client
    def initialize(repo)
      @repo = repo
      @config = Config.instance
      @comment_cache = {}
      @pull_id_cache = {}
    end

    def env_pull_id
      if (pull_request = ENV['PULL_REQUEST_ID'])
        warn "[DEPRECATION] `PULL_REQUEST_ID` is deprecated.  Please use `PRONTO_PULL_REQUEST_ID` instead."
      end

      pull_request ||= ENV['PRONTO_PULL_REQUEST_ID']
      pull_request.to_i if pull_request
    end
  end
end
