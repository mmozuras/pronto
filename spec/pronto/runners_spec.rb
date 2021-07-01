module Pronto
  describe Runners do
    describe '#run' do
      subject { described_class.new(runners, config).run(patches) }
      let(:patches) { double(commit: nil, none?: false) }
      let(:config) { Config.new }

      let(:fake_runner) do
        Class.new do
          def self.title
            'fake_runner'
          end

          def initialize(_, _); end

          def run
            [1, nil, [3]]
          end
        end
      end

      context 'no runners' do
        let(:runners) { [] }
        it { should be_empty }
      end

      context 'fake runner' do
        let(:runners) { [fake_runner] }
        it { should == [1, 3] }

        context 'rejects excluded files' do
          before { config.stub(:excluded_files) { ['1'] } }
          let(:patches) { [double(new_file_full_path: 1)] }
          it { should be_empty }
        end

        context 'max warnings' do
          before { config.stub(:excluded_files) { [] } }
          before { config.stub(:max_warnings) { 1 } }
          it { should == [1] }
        end
      end

      context 'when multiple runners exist' do # rubocop:disable Metrics/BlockLength
        let(:fake_runner_2) do
          Class.new(fake_runner) do
            def self.title
              'fake_runner_2'
            end

            def run
              [2, nil, [6]]
            end
          end
        end

        let(:fake_runner_3) do
          Class.new(fake_runner) do
            def self.title
              'fake_runner_2'
            end

            def run
              [5, nil, [10]]
            end
          end
        end

        let(:runners) { [fake_runner, fake_runner_2, fake_runner_3] }

        context 'when runners are not filtered' do
          it { should == [1, 3, 2, 6, 5, 10] }
        end

        context 'when runners are listed in config' do
          before { config.stub(:runners) { ['fake_runner'] } }

          it { should == [1, 3] }
        end

        context 'when some runners are skipped via config' do
          before { config.stub(:skip_runners) { ['fake_runner'] } }

          it { should == [2, 6, 5, 10] }
        end

        context 'when same runners are skipped and some are listed' do
          before do
            config.stub(:runners) { %w[fake_runner fake_runner_3] }
            config.stub(:skip_runners) { %w[fake_runner_3] }
          end

          it { should == [1, 3] }
        end
      end
    end
  end
end
