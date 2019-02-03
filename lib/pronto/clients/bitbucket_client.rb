class BitbucketClient
  BITBUCKET_ACCESS_TOKEN_URL = "https://bitbucket.org/site/oauth2/access_token".freeze
  BITBUCKET_ACCESS_TOKEN_PAYLOAD = { grant_type: :client_credentials }.freeze

  include HTTParty
  base_uri 'https://api.bitbucket.org/2.0/repositories'

  def initialize(key, secret)
    options = {
      basic_auth: { username: key, password: secret },
      body: BITBUCKET_ACCESS_TOKEN_PAYLOAD
    }

    self.response = self.class.post(BITBUCKET_ACCESS_TOKEN_URL, options)
  end

  def commit_comments(slug, sha)
    response = get("/#{slug}/commit/#{sha}/comments")
    openstruct(response)
  end

  def create_commit_comment(slug, sha, body, path, position)
    post("/#{slug}/commit/#{sha}/comments", body, path, position)
  end

  def pull_comments(slug, pull_id)
    response = get("/#{slug}/pullrequests/#{pull_id}/comments")
    openstruct(response['values'])
  end

  def pull_requests(slug)
    response = get("/#{slug}/pullrequests?state=OPEN")
    openstruct(response['values'])
  end

  def create_pull_comment(slug, pull_id, body, path, position)
    post("/#{slug}/pullrequests/#{pull_id}/comments", body, path, position)
  end

  def approve_pull_request(slug, pull_id)
    self.class.post("#{slug}/pullrequests/#{pull_id}/approve" ,access_token_options)
  end

  def unapprove_pull_request(slug, pull_id)
    self.class.delete("#{slug}/pullrequests/#{pull_id}/approve", access_token_options)
  end

  private

  attr_reader :response

  def openstruct(response)
    response.map { |r| OpenStruct.new(r) }
  end

  def post(url, body, path, position)
    options = {
      body: {
        content: { raw: body },
        inline: {
          to: position,
          path: path
        }
      }.to_json,
      headers: {
        "Content-Type" => "application/json",
        **access_token_header
      },
      query: access_token_query
    }

    self.class.post(url, options)
  end

  def get(url)
    self.class.get(url, access_token_options).parsed_response
  end

  def access_token_options
    {
      query: access_token_query,
      headers: access_token_header
    }
  end

  def access_token_query
    { access_token: access_token }
  end

  def access_token_header
    { "Authorization": "Bearer #{access_token}" }
  end

  def access_token
    response[:access_token]
  end

  def response=(response)
    @response = JSON.parse(response.body, symbolize_names: true)
  end
end
