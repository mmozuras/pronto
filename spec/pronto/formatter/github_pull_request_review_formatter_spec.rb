module Pronto
  module Formatter
    describe GithubPullRequestReviewFormatter do
      let(:formatter) { described_class.new }

      let(:repo) { Git::Repository.new('spec/fixtures/test.git') }

      describe '#format' do
        subject { formatter.format(messages, repo, patches) }
        let(:messages) { [message, message] }
        let(:message) { Message.new(patch.new_file_full_path, line, :info, '') }
        let(:patch) { repo.show_commit('64dadfd').first }
        let(:line) { patch.added_lines.first }
        let(:patches) { repo.diff('64dadfd^') }

        before do
          ENV['PRONTO_PULL_REQUEST_ID'] = '10'

          Octokit::Client.any_instance
            .should_receive(:pull_comments)
            .once
            .and_return([])
        end

        specify do
          Octokit::Client.any_instance
            .should_receive(:create_pull_request_review)
            .once

          subject
        end
      end
    end
  end
end
