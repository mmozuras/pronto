class BitbucketClient
  include HTTParty
  base_uri 'https://api.bitbucket.org/1.0/repositories'

  def initialize(username, password)
    self.class.basic_auth(username, password)
  end

  def commit_comments(slug, sha)
    response = get("/#{slug}/changesets/#{sha}/comments")
    openstruct(response)
  end

  def create_commit_comment(slug, sha, body, path, position)
    post("/#{slug}/changesets/#{sha}/comments", body, path, position)
  end

  def pull_comments(slug, pull_id)
    response = get("/#{slug}/pullrequests/#{pull_id}/comments")
    openstruct(response)
  end

  def pull_requests(slug)
    base = 'https://api.bitbucket.org/2.0/repositories'
    response = get("#{base}/#{slug}/pullrequests?state=OPEN&pagelen=50")
    openstruct(response['values'])
  end

  def create_pull_comment(slug, pull_id, body, path, position)
    post("/#{slug}/pullrequests/#{pull_id}/comments", body, path, position)
  end

  private

  def openstruct(response)
    response.map { |r| OpenStruct.new(r) }
  end

  def post(url, body, path, position)
    options = {
      body: {
        content: body,
        line_to: position,
        filename: path
      }
    }
    self.class.post(url, options)
  end

  def get(url)
    self.class.get(url).parsed_response
  end
end
