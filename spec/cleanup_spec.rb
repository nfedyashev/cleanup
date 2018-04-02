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
    FileUtils.rm_r  root_path
  end

  let(:root_path) { "tmp/spec/fixture" }

  subject { -> { @cleanup.explore } }

  context 'Downloads/' do
    before(:example) do
      touch "Downloads/file.torrent"
      touch "Downloads/index.htm"
      touch "Downloads/.gitkeep"
      touch "Downloads/steam_latest.deb"
      touch "Downloads/manual.doc"
      touch "Downloads/dubplate-fm.mp3"
    end

    it { is_expected.to change{ @cleanup.execute_commands }.to(["mv tmp/spec/fixture/Downloads/manual.doc tmp/spec/fixture/Documents/Unsorted",
                                                                "rm tmp/spec/fixture/Downloads/index.htm",
                                                                "rm tmp/spec/fixture/Downloads/steam_latest.deb",
                                                                "rm tmp/spec/fixture/Downloads/file.torrent"]) }
  end
end

