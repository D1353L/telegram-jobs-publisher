# frozen_string_literal: true

require 'fileutils'

describe Telegram::JobsPublisher::FileLogger do
  subject { described_class }
  let(:path_with_dir) { 'test_dir/test1.log' }
  let(:path_root_dir) { 'test2.log' }

  after(:each) do
    if File.exist?(path_with_dir)
      dir = File.dirname(path_with_dir)
      FileUtils.remove_dir(dir)
    end
    FileUtils.rm(path_root_dir) if File.exist?(path_root_dir)
  end

  describe 'creating new instance' do
    context 'with empty path specified' do
      it 'throws an error' do
        expect { subject.new('') }.to raise_error(Errno::ENOENT)
      end
    end

    context 'with valid path specified' do
      context 'existing file' do
        before do
          dir = File.dirname(path_with_dir)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
        end

        it 'uses existing file' do
          filename = subject.new(path_with_dir).instance_variable_get(:@logdev)
                            .instance_variable_get(:@filename)
          expect(filename).to eq path_with_dir
        end
      end

      context 'not existing file' do
        context 'with dir in path' do
          before do
            subject.new(path_with_dir)
          end

          it 'creates new dir and file' do
            expect(File.file?(path_with_dir)).to be true
          end
        end

        context 'without dir in path' do
          before do
            subject.new(path_root_dir)
          end

          it 'creates new file in the root of project' do
            expect(File.file?(path_root_dir)).to be true
          end
        end
      end
    end
  end
end
