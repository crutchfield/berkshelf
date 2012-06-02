require 'kcd/core_ext'
require 'kcd/errors'
require 'chef/knife'
require 'chef/rest'
require 'chef/platform'
require 'chef/cookbook/metadata'

module KnifeCookbookDependencies
  DEFAULT_FILENAME = 'Cookbookfile'.freeze
  COOKBOOKS_DIRECTORY = 'cookbooks'
  TMP_DIRECTORY = File.join(ENV['TMPDIR'] || ENV['TEMP'], 'knife_cookbook_dependencies')
  FileUtils.mkdir_p TMP_DIRECTORY

  autoload :InitGenerator, 'kcd/init_generator'
  autoload :CookbookSource, 'kcd/cookbook_source'
  autoload :Downloader, 'kcd/downloader'
  autoload :Resolver, 'kcd/resolver'

  class << self
    attr_accessor :ui

    def root
      File.join(File.dirname(__FILE__), '..')
    end

    def cookbook_store
      File.expand_path(File.join("~/.bookshelf"))
    end

    def shelf
      @shelf ||= KCD::Shelf.new
    end

    def clear_shelf!
      @shelf = nil
    end

    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    end

    def downloader
      @downloader ||= Downloader.new(cookbook_store)
    end

    def clean
      clear_shelf!
      Lockfile.remove!
      FileUtils.rm_rf COOKBOOKS_DIRECTORY
      FileUtils.rm_rf TMP_DIRECTORY
    end

    # Ascend the directory structure from the given path to find a
    # metadata.rb file of a Chef Cookbook. If no metadata.rb file
    # was found, nil is returned.
    #
    # @returns[Pathname] 
    #   path to metadata.rb 
    def find_metadata(path = Dir.pwd)
      path = Pathname.new(path)
      path.ascend do |potential_root|
        if potential_root.entries.collect(&:to_s).include?('metadata.rb')
          return potential_root.join('metadata.rb')
        end
      end
    end
  end
end

# Alias for {KnifeCookbookDependencies}
KCD = KnifeCookbookDependencies

require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'

require 'kcd/version'
require 'kcd/shelf'
require 'kcd/dsl'
require 'kcd/cookbookfile'
require 'kcd/lockfile'
require 'kcd/git'
