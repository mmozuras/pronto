module Pronto
  describe Runners do
    describe '#run' do
      subject { described_class.new(runners, config).run(patches) }
      let(:patches) { double(commit: nil, none?: false) }
      let(:config) { Config.instance }

      context 'no runners' do
        let(:runners) { [] }
        it { should be_empty }
      end

      context 'fake runner' do
        class FakeRunner
          def self.title
            'fake_runner'
          end

          def initialize(_, _); end

          def run
            [1, nil, [3]]
          end
        end

        let(:runners) { [FakeRunner] }
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
    end
  end
end
