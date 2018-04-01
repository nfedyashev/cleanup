require 'pry'

class Cleanup
  def initialize(root_path)
    @root_path = root_path
    @execute_commands = []
  end

  def delete_all_in_path_with_ext(in_path:, with_ext:)
    -> (item) do
      return if item.nil?
      return unless File.extname(item) == ".#{with_ext}"
      return unless item.start_with? File.join(@root_path, in_path)

      %(rm #{item})
    end
  end

  def explore
    #Dir.glob("**/*/") # for directories
    #Dir.glob("**/*") # for all files

    Dir.glob("#{@root_path}/**/*") do |item|
      next if File.directory? item

      filters = [
          delete_all_in_path_with_ext(in_path: 'Downloads', with_ext: 'torrent'),
          delete_all_in_path_with_ext(in_path: 'Downloads', with_ext: 'deb'),
          delete_all_in_path_with_ext(in_path: 'Downloads', with_ext: 'htm'),
          delete_all_in_path_with_ext(in_path: 'Downloads', with_ext: 'html')
      ]

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
end
