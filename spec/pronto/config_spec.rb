module Pronto
  describe Config do
    let(:config) do
      config = described_class.instance
      config.config_hash = config_hash
      config
    end

    let(:config_hash) { {} }

    describe '#path=' do
      pending # TODO
    end

    describe '#config_hash=' do
      pending # TODO
    end

    describe '#config_hash' do
      pending # TODO
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
