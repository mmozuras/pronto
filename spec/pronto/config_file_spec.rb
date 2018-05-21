module Pronto
  describe ConfigFile do
    context '#new' do
      context 'custom config file' do
        let(:path) { '/tmp/pronto.yml' }
        let(:config_file) { described_class.new(path) }

        subject { config_file.instance_variable_get('@path') }

        before do
          File.should_receive(:exist?)
            .with(path)
            .and_return(true)
        end

        it { should == path }
      end

      context 'unexisting config file path' do
        let(:path) { '/tmp/pronto.yml' }

        subject { described_class.new(path) }

        before do
          File.should_receive(:exist?)
            .with(path)
            .and_return(false)
        end

        specify do
          -> { subject }.should raise_error(Pronto::Error, "configuration file `#{path}` missing")
        end
      end

      context 'no config file path' do
        let(:config_file) { described_class.new }

        subject { config_file.instance_variable_get('@path') }

        before do
          File.should_receive(:exist?)
            .with(described_class::DEFAULT_FILE_PATH)
            .and_return(false)
        end

        it { should == nil }
      end

      context 'default config file path' do
        let(:config_file) { described_class.new }

        subject { config_file.instance_variable_get('@path') }

        before do
          File.should_receive(:exist?)
            .with(described_class::DEFAULT_FILE_PATH)
            .and_return(true)
        end

        it { should == described_class::DEFAULT_FILE_PATH }
      end
    end

    describe '#to_h' do
      let(:config_file) { described_class.new }

      subject { config_file.to_h }

      context 'not existing config file' do
        it { should include('all' => { 'exclude' => [], 'include' => [] }) }
        it do
          should include(
            'github' => {
              'slug' => nil,
              'access_token' => nil,
              'api_endpoint' => 'https://api.github.com/',
              'web_endpoint' => 'https://github.com/'
            }
          )
        end
        it do
          should include(
            'gitlab' => {
              'slug' => nil,
              'api_private_token' => nil,
              'api_endpoint' => 'https://gitlab.com/api/v3'
            }
          )
        end
        it { should include('runners' => []) }
        it { should include('formatters' => []) }
      end

      context 'only global excludes in file' do
        before do
          File.should_receive(:exist?)
            .and_return(true)

          YAML.should_receive(:load_file)
            .and_return('all' => { 'exclude' => ['a/**/*.rb'] })
        end

        it do
          should include(
            'all' => {
              'exclude' => ['a/**/*.rb'], 'include' => []
            }
          )
        end
      end

      context 'a value is set to false' do
        before do
          File.should_receive(:exist?)
            .and_return(true)

          YAML.should_receive(:load_file)
            .and_return('verbose' => false)
        end

        it { should include('verbose' => false) }
      end
    end
  end
end
