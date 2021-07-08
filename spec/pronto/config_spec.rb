module Pronto
  describe Config do
    let(:config) { described_class.new(config_hash) }
    let(:config_hash) { {} }

    describe '#default_commit' do
      subject { config.default_commit }

      context 'from env variable' do
        before { stub_const('ENV', 'PRONTO_DEFAULT_COMMIT' => 'development') }
        it { should == 'development' }
      end

      context 'from config hash' do
        let(:config_hash) { { 'default_commit' => 'development' } }
        it { should == 'development' }
      end

      context 'from default value' do
        it { should == 'master' }
      end
    end

    describe '#github_slug' do
      subject { config.github_slug }

      context 'from env variable' do
        before { stub_const('ENV', 'PRONTO_GITHUB_SLUG' => 'prontolabs/pronto') }
        it { should == 'prontolabs/pronto' }
      end

      context 'from config hash' do
        let(:config_hash) { { 'github' => { 'slug' => 'rails/rails' } } }
        it { should == 'rails/rails' }
      end
    end

    describe '#github_web_endpoint' do
      subject { config.github_web_endpoint }

      context 'from env variable' do
        before { stub_const('ENV', 'PRONTO_GITHUB_WEB_ENDPOINT' => '4.2.2.2') }
        it { should == '4.2.2.2' }
      end

      context 'from config hash' do
        let(:config_hash) { { 'github' => { 'web_endpoint' => 'localhost' } } }
        it { should == 'localhost' }
      end

      context 'default' do
        let(:config_hash) { ConfigFile::EMPTY }
        it { should == 'https://github.com/' }
      end
    end

    describe '#github_hostname' do
      subject { config.github_hostname }
      let(:config_hash) { ConfigFile::EMPTY }
      it { should == 'github.com' }
    end

    describe '#github_review_type' do
      subject { config.github_review_type }

      context 'from env variable' do
        before { stub_const('ENV', 'PRONTO_GITHUB_REVIEW_TYPE' => 'request_changes') }
        it { should == 'REQUEST_CHANGES' }
      end

      context 'from config hash' do
        let(:config_hash) { { 'github' => { 'review_type' => 'something_else' } } }
        it { should == 'COMMENT' }
      end

      context 'default' do
        let(:config_hash) { ConfigFile::EMPTY }
        it { should == 'COMMENT' }
      end
    end

    describe '#gitlab_slug' do
      subject { config.gitlab_slug }

      context 'from env variable' do
        before { stub_const('ENV', 'PRONTO_GITLAB_SLUG' => 'rick/deckard') }
        it { should == 'rick/deckard' }
      end

      context 'from config hash' do
        let(:config_hash) { { 'gitlab' => { 'slug' => 'ruby/ruby' } } }
        it { should == 'ruby/ruby' }
      end
    end

    {
      max_warnings: {
        default_value: nil
      },
      warnings_per_review: {
        default_value: ConfigFile::DEFAULT_WARNINGS_PER_REVIEW
      }
    }.each do |setting_name, specifics|
      describe "##{setting_name}" do
        subject { config.public_send(setting_name) }

        context 'from env variable' do
          context 'with a valid value' do
            before { stub_const('ENV', "PRONTO_#{setting_name.upcase}" => '20') }
            it { should == 20 }
          end

          context 'with an invalid value' do
            before { stub_const('ENV', "PRONTO_#{setting_name.upcase}" => 'twenty') }

            specify do
              -> { subject }.should raise_error(ArgumentError)
            end
          end
        end

        context 'from config hash' do
          let(:config_hash) { { setting_name.to_s => 40 } }
          it { should == 40 }
        end

        context 'default' do
          let(:config_hash) { ConfigFile::EMPTY }
          it { should == specifics[:default_value] }
        end
      end
    end

    describe '#message_format' do
      subject { config.message_format('whatever') }

      context 'when there is an entry in the config file' do
        let(:config_hash) { { 'whatever' => { 'format' => whatever_format } } }
        let(:whatever_format) { "that's just like your opinion man" }

        it { should == whatever_format }
      end

      context 'when there is no entry in the config file' do
        let(:config_hash) { ConfigFile::EMPTY }

        it { should == ConfigFile::DEFAULT_MESSAGE_FORMAT }
      end
    end
  end
end
