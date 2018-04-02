require 'pry'

class Cleanup
  DOCUMENT_EXTS = ['.doc'].freeze

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

      mv item, 'Documents/Unsorted'
    end
  end

  def explore
    #Dir.glob("**/*/") # for directories
    #Dir.glob("**/*") # for all files

    Dir.glob("#{@root_path}/**/*") do |item|
      next if File.directory? item

      files_with_extensions_to_delete_from_all_base_folers = [
          'torrent',
          'deb',
          'jpg',
          'png',
          'htm',
          'html'
      ]

      filters = files_with_extensions_to_delete_from_all_base_folers.inject([]) do |r, ext|
        r << delete_all_in_path_with_ext(in_path: 'Desktop', with_ext: ext)
        r << delete_all_in_path_with_ext(in_path: 'Downloads', with_ext: ext)
      end
      filters << move_unsorted_documents(in_path: 'Downloads')

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
