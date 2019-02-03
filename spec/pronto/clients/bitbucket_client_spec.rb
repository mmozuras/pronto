module Pronto
  describe BitbucketClient do
    let(:client) { described_class.new('username', 'password') }

    describe '#create_commit_comment' do
      subject { client.create_commit_comment(slug, sha, body, path, position) }
      let(:slug) { 'prontolabs/pronto' }
      let(:sha) { '123' }
      let(:body) { 'comment' }
      let(:path) { 'path/to/file' }
      let(:position) { 1 }

      context 'success' do
        before { BitbucketClient.stub(:post).and_return(response) }
        let(:response) { double('Response', success?: true, body: {}.to_json) }
        its(:success?) { should be_truthy }
      end
    end

    describe '#approve_pull_request' do
      subject { client.approve_pull_request(slug, pull_id) }
      let(:slug) { 'prontolabs/pronto' }
      let(:pull_id) { 1 }

      context 'success' do
        before { BitbucketClient.stub(:post).and_return(response) }
        let(:response) { double('Response', success?: true, body: {}.to_json) }
        its(:success?) { should be_truthy }
      end
    end

    describe '#unapprove_pull_request' do
      subject { client.unapprove_pull_request(slug, pull_id) }
      let(:slug) { 'prontolabs/pronto' }
      let(:pull_id) { 1 }

      context 'success' do
        before { BitbucketClient.stub(:delete).and_return(response) }
        let(:response) { double('Response', success?: true) }
        its(:success?) { should be_truthy }
      end
    end
  end
end
