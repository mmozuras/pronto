module Pronto
  class Bitbucket < Client
    def pull_comments(sha)
      @comment_cache["#{pull_id}/#{sha}"] ||= begin
        client.pull_comments(slug, pull_id).map do |comment|
          Comment.new(sha, comment.content, comment.filename, comment.line_to)
        end
      end
    end

    def commit_comments(sha)
      @comment_cache[sha.to_s] ||= begin
        client.commit_comments(slug, sha).map do |comment|
          Comment.new(sha, comment.content, comment.filename, comment.line_to)
        end
      end
    end

    def create_commit_comment(comment)
      @config.logger.log("Creating commit comment on #{comment.sha}")
      client.create_commit_comment(slug, comment.sha, comment.body,
                                   comment.path, comment.position)
    end

    def create_pull_comment(comment)
      if comment.path && comment.position
        @config.logger.log("Creating pull request comment on #{pull_id}")
        client.create_pull_comment(slug, pull_id, comment.body,
                                   comment.path, comment.position)
      else
        create_commit_comment(comment)
      end
    end

    def approve_pull_request
      client.approve_pull_request(slug, pull_id)
    end

    def unapprove_pull_request
      client.unapprove_pull_request(slug, pull_id)
    end
    private

    def slug
      return bitbucket_slug if bitbucket_slug
      @slug ||= begin
        @repo.remote_urls.map do |url|
          hostname = Regexp.escape(bitbucket_hostname)
          match = %r{.*#{hostname}(:|\/)(?<slug>.*?)(?:\.git)?\z}.match(url)
          match[:slug] if match
        end.compact.first
      end
    end

    def bitbucket_hostname
      @config.bitbucket_hostname
    end

    def bitbucket_slug
      @config.bitbucket_slug
    end

    def client
      @client ||= BitbucketClient.new(@config.bitbucket_key,
                                      @config.bitbucket_secret)
    end

    def pull_id
      pull ? pull.id.to_i : env_pull_id
    end

    def pull
      @pull ||= if env_pull_id
                  pull_requests.find { |pr| pr.id.to_i == env_pull_id }
                elsif @repo.branch
                  pull_requests.find do |pr|
                    pr.source['branch']['name'] == @repo.branch
                  end
                end
    end

    def pull_requests
      @pull_requests ||= client.pull_requests(slug)
    end
  end
end
