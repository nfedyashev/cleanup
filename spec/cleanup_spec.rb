require 'spec_helper'
require 'fileutils'

RSpec.describe Cleanup do
  def touch(path)
    FileUtils.mkdir_p root_path
    FileUtils.mkdir_p File.join(root_path, File.dirname(path))

    FileUtils.touch File.join(root_path, path)
  end

  before(:example) do
    @cleanup = Cleanup.new(root_path)
    FileUtils.rm_r root_path
  end

  let(:root_path) { "tmp/spec/fixture" }

  subject { @cleanup.explore ; @cleanup.execute_commands }

  before(:example) do
    touch "Downloads/file.torrent"
    touch "Downloads/index.htm"
    touch "Downloads/.gitkeep"
    touch "Downloads/steam_latest.deb"
    touch "Downloads/manual.doc"
    touch "Downloads/anki-2.0.47-amd64.tar.bz2"
    touch "Desktop/Scan1.PDF"
    touch "Downloads/dubplate-fm.mp3"
  end

  it { is_expected.to contain_exactly("mv tmp/spec/fixture/Downloads/manual.doc tmp/spec/fixture/Documents/Unsorted",
                                                       "rm tmp/spec/fixture/Downloads/index.htm",
                                                       "rm tmp/spec/fixture/Downloads/steam_latest.deb",
                                                       "rm tmp/spec/fixture/Downloads/file.torrent",
                                                       "rm tmp/spec/fixture/Downloads/anki-2.0.47-amd64.tar.bz2",
                                                       "rm tmp/spec/fixture/Downloads/dubplate-fm.mp3")}
end

