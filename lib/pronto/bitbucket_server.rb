module Pronto
  class BitbucketServer < Bitbucket
    def pull_comments(sha)
      @comment_cache["#{pull_id}/#{sha}"] ||= begin
        client.pull_comments(slug, pull_id).map do |comment|
          anchor = comment['commentAnchor']
          if anchor
            Comment.new(sha, comment['comment']['text'],
                        anchor['path'], anchor['line'])
          end
        end.compact
      end
    end

    private

    def client
      @client ||= BitbucketServerClient.new(@config.bitbucket_server_username,
                                            @config.bitbucket_server_password,
                                            @config.bitbucket_server_api_endpoint)
    end

    def pull
      @pull ||= if env_pull_id
                  pull_requests.find { |pr| pr.id.to_i == env_pull_id }
                elsif @repo.branch
                  pull_requests.find do |pr|
                    pr['fromRef']['displayId'] == @repo.branch
                  end
                end
    end

    def bitbucket_hostname
      @config.bitbucket_server_hostname
    end

    def bitbucket_slug
      @config.bitbucket_server_slug
    end
  end
end
