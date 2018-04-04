require 'pry'

class Cleanup
  DOCUMENT_EXTS = [
      '.doc',
      '.djvu',
      '.docx',
      '.epub',
      '.mobi',
      '.xlsx',
      '.pdf'
  ].freeze

  DESTINATION_FOR_UNSORTED_DOCUMENTS = 'Documents/Unsorted'.freeze

  BASE_FOLERS = [
      'Desktop',
      'Downloads'
  ].freeze

  FILES_WITH_EXTENSIONS_TO_DELETE_FROM_ALL_BASE_FOLERS = [
      'torrent',
      'deb',
      'gz', #.tar.gz - test it
      'zip',
      'rar',

      'jpeg',
      'jpg',
      'png',

      'htm',
      'html'
  ]

  def initialize(root_path)
    @root_path = root_path
    @execute_commands = []
  end

  def delete_all_in_path_with_ext(in_path:, with_ext:)
    -> (item) do
      return if item.nil?
      return unless File.extname(item) == ".#{with_ext}"
      return unless item.start_with? File.join(@root_path, in_path)

      rm item
    end
  end

  def move_unsorted_documents(in_path:)
    -> (item) do
      return if item.nil?
      return unless DOCUMENT_EXTS.include?(File.extname(item))
      return unless item.start_with? File.join(@root_path, in_path)

      mv item, DESTINATION_FOR_UNSORTED_DOCUMENTS
    end
  end

  def explore
    #Dir.glob("**/*/") # for directories
    #Dir.glob("**/*") # for all files

    Dir.glob("#{@root_path}/**/*") do |item|
      next if File.directory? item

      filters = FILES_WITH_EXTENSIONS_TO_DELETE_FROM_ALL_BASE_FOLERS.inject([]) do |r, ext|
        BASE_FOLERS.each do |folder|
          r << delete_all_in_path_with_ext(in_path: folder, with_ext: ext)
        end
        r
      end
      BASE_FOLERS.each do |folder|
        filters << move_unsorted_documents(in_path: folder)
      end

      result_command = nil
      filters.each do |filter|
        result_command = filter.call item

        break unless result_command.nil?
      end

      @execute_commands << result_command unless result_command.nil?
    end
  end

  def execute_commands
    @execute_commands
  end

  private

  def rm(item)
    %(rm #{item})
  end

  def mv(item, destination)
    %(mv #{item} #{File.join(@root_path, destination)})
  end
end
