# encoding: utf-8

# Load Ruby Core Libraries
require 'rubygems'
require 'fileutils'
require 'tempfile'
require 'yaml'
require 'etc'

# Attempt load to POpen4 and Thor Libraries
begin
  gem 'POpen4', '~> 0.1.4'
  gem 'thor',   '~> 0.14.6'
  require 'popen4'
  require 'thor'
rescue LoadError
  puts "\nBackup requires Thor to load the CLI Utility (Command Line Interface Utility) and POpen4 to determine the status of the unix processes."
  puts "Please install both the Thor and POpen4 libraries first:\n\ngem install thor -v '~> 0.14.6'\ngem install POpen4 -v '~> 0.1.4'"
  exit 1
end

##
# The Backup Ruby Gem
module Backup

  ##
  # List the available database, storage, compressor, encryptor and notifier constants.
  # These are used to dynamically define these constants as classes inside Backup::Finder
  # to provide a nicer configuration file DSL syntax to the users. Adding existing constants
  # to the arrays below will enable the user to use a constant instead of a string.
  # Example, instead of:
  #  database "MySQL" do |mysql|
  # You can do:
  #  database MySQL do |mysql|
  DATABASES   = ['MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'Riak']
  STORAGES    = ['S3', 'CloudFiles', 'Ninefold', 'Dropbox', 'FTP', 'SFTP', 'SCP', 'RSync', 'Local']
  COMPRESSORS = ['Gzip', 'Bzip2', 'Lzma', 'Pbzip2']
  ENCRYPTORS  = ['OpenSSL', 'GPG']
  SYNCERS     = ['RSync', 'S3']
  NOTIFIERS   = ['Mail', 'Twitter', 'Campfire', 'Presently', 'Prowl', 'Hipchat']

  ##
  # Backup's internal paths
  LIBRARY_PATH       = File.join(File.dirname(__FILE__), 'backup')
  CLI_PATH           = File.join(LIBRARY_PATH, 'cli')
  STORAGE_PATH       = File.join(LIBRARY_PATH, 'storage')
  DATABASE_PATH      = File.join(LIBRARY_PATH, 'database')
  COMPRESSOR_PATH    = File.join(LIBRARY_PATH, 'compressor')
  ENCRYPTOR_PATH     = File.join(LIBRARY_PATH, 'encryptor')
  NOTIFIER_PATH      = File.join(LIBRARY_PATH, 'notifier')
  SYNCER_PATH        = File.join(LIBRARY_PATH, 'syncer')
  CONFIGURATION_PATH = File.join(LIBRARY_PATH, 'configuration')
  EXCEPTION_PATH     = File.join(LIBRARY_PATH, 'exception')
  TEMPLATE_PATH      = File.expand_path('../../templates', __FILE__)

  ##
  # Backup's Environment paths
  USER        = ENV['USER'] || Etc.getpwuid.name
  HOME        = ENV['HOME'] || ""
  PATH        = File.join(HOME, 'Backup')
  DATA_PATH   = File.join(HOME, 'Backup', 'data')
  CONFIG_FILE = File.join(HOME, 'Backup', 'config.rb')
  LOG_PATH    = File.join(HOME, 'Backup', 'log')
  CACHE_PATH  = File.join(HOME, 'Backup', '.cache')
  TMP_PATH    = File.join(HOME, 'Backup', '.tmp')

  ##
  # Autoload Backup base files
  autoload :Model,      File.join(LIBRARY_PATH, 'model')
  autoload :Archive,    File.join(LIBRARY_PATH, 'archive')
  autoload :Packager,   File.join(LIBRARY_PATH, 'packager')
  autoload :Cleaner,    File.join(LIBRARY_PATH, 'cleaner')
  autoload :Splitter,   File.join(LIBRARY_PATH, 'splitter')
  autoload :Finder,     File.join(LIBRARY_PATH, 'finder')
  autoload :Dependency, File.join(LIBRARY_PATH, 'dependency')
  autoload :Logger,     File.join(LIBRARY_PATH, 'logger')
  autoload :Version,    File.join(LIBRARY_PATH, 'version')

  ##
  # Autoload Backup CLI files
  module CLI
    autoload :Helpers, File.join(CLI_PATH, 'helpers')
    autoload :Utility, File.join(CLI_PATH, 'utility')
  end

  ##
  # Autoload Backup storage files
  module Storage
    autoload :Base,       File.join(STORAGE_PATH, 'base')
    autoload :Object,     File.join(STORAGE_PATH, 'object')
    autoload :S3,         File.join(STORAGE_PATH, 's3')
    autoload :CloudFiles, File.join(STORAGE_PATH, 'cloudfiles')
    autoload :Ninefold,   File.join(STORAGE_PATH, 'ninefold')
    autoload :Dropbox,    File.join(STORAGE_PATH, 'dropbox')
    autoload :FTP,        File.join(STORAGE_PATH, 'ftp')
    autoload :SFTP,       File.join(STORAGE_PATH, 'sftp')
    autoload :SCP,        File.join(STORAGE_PATH, 'scp')
    autoload :RSync,      File.join(STORAGE_PATH, 'rsync')
    autoload :Local,      File.join(STORAGE_PATH, 'local')
  end

  ##
  # Autoload Backup syncer files
  module Syncer
    autoload :Base,  File.join(SYNCER_PATH, 'base')
    autoload :RSync, File.join(SYNCER_PATH, 'rsync')
    autoload :S3,    File.join(SYNCER_PATH, 's3')
  end

  ##
  # Autoload Backup database files
  module Database
    autoload :Base,       File.join(DATABASE_PATH, 'base')
    autoload :MySQL,      File.join(DATABASE_PATH, 'mysql')
    autoload :PostgreSQL, File.join(DATABASE_PATH, 'postgresql')
    autoload :MongoDB,    File.join(DATABASE_PATH, 'mongodb')
    autoload :Redis,      File.join(DATABASE_PATH, 'redis')
    autoload :Riak,       File.join(DATABASE_PATH, 'riak')
  end

  ##
  # Autoload compressor files
  module Compressor
    autoload :Base,  File.join(COMPRESSOR_PATH, 'base')
    autoload :Gzip,  File.join(COMPRESSOR_PATH, 'gzip')
    autoload :Bzip2, File.join(COMPRESSOR_PATH, 'bzip2')
    autoload :Pbzip2, File.join(COMPRESSOR_PATH, 'pbzip2')
    autoload :Lzma,  File.join(COMPRESSOR_PATH, 'lzma')
  end

  ##
  # Autoload encryptor files
  module Encryptor
    autoload :Base,    File.join(ENCRYPTOR_PATH, 'base')
    autoload :OpenSSL, File.join(ENCRYPTOR_PATH, 'open_ssl')
    autoload :GPG,     File.join(ENCRYPTOR_PATH, 'gpg')
  end

  ##
  # Autoload notification files
  module Notifier
    autoload :Base,      File.join(NOTIFIER_PATH, 'base')
    autoload :Binder,    File.join(NOTIFIER_PATH, 'binder')
    autoload :Mail,      File.join(NOTIFIER_PATH, 'mail')
    autoload :Twitter,   File.join(NOTIFIER_PATH, 'twitter')
    autoload :Campfire,  File.join(NOTIFIER_PATH, 'campfire')
    autoload :Presently, File.join(NOTIFIER_PATH, 'presently')
    autoload :Prowl,     File.join(NOTIFIER_PATH, 'prowl')
    autoload :Hipchat,   File.join(NOTIFIER_PATH, 'hipchat')
  end

  ##
  # Autoload Backup configuration files
  module Configuration
    autoload :Base,     File.join(CONFIGURATION_PATH, 'base')
    autoload :Helpers,  File.join(CONFIGURATION_PATH, 'helpers')

    module Notifier
      autoload :Base,      File.join(CONFIGURATION_PATH, 'notifier', 'base')
      autoload :Mail,      File.join(CONFIGURATION_PATH, 'notifier', 'mail')
      autoload :Twitter,   File.join(CONFIGURATION_PATH, 'notifier', 'twitter')
      autoload :Campfire,  File.join(CONFIGURATION_PATH, 'notifier', 'campfire')
      autoload :Presently, File.join(CONFIGURATION_PATH, 'notifier', 'presently')
      autoload :Prowl,     File.join(CONFIGURATION_PATH, 'notifier', 'prowl')
      autoload :Hipchat,   File.join(CONFIGURATION_PATH, 'notifier', 'hipchat')
    end

    module Encryptor
      autoload :Base,    File.join(CONFIGURATION_PATH, 'encryptor', 'base')
      autoload :OpenSSL, File.join(CONFIGURATION_PATH, 'encryptor', 'open_ssl')
      autoload :GPG,     File.join(CONFIGURATION_PATH, 'encryptor', 'gpg')
    end

    module Compressor
      autoload :Base,  File.join(CONFIGURATION_PATH, 'compressor', 'base')
      autoload :Gzip,  File.join(CONFIGURATION_PATH, 'compressor', 'gzip')
      autoload :Bzip2, File.join(CONFIGURATION_PATH, 'compressor', 'bzip2')
      autoload :Pbzip2, File.join(CONFIGURATION_PATH, 'compressor', 'pbzip2')
      autoload :Lzma,  File.join(CONFIGURATION_PATH, 'compressor', 'lzma')
    end

    module Storage
      autoload :Base,       File.join(CONFIGURATION_PATH, 'storage', 'base')
      autoload :S3,         File.join(CONFIGURATION_PATH, 'storage', 's3')
      autoload :CloudFiles, File.join(CONFIGURATION_PATH, 'storage', 'cloudfiles')
      autoload :Ninefold,   File.join(CONFIGURATION_PATH, 'storage', 'ninefold')
      autoload :Dropbox,    File.join(CONFIGURATION_PATH, 'storage', 'dropbox')
      autoload :FTP,        File.join(CONFIGURATION_PATH, 'storage', 'ftp')
      autoload :SFTP,       File.join(CONFIGURATION_PATH, 'storage', 'sftp')
      autoload :SCP,        File.join(CONFIGURATION_PATH, 'storage', 'scp')
      autoload :RSync,      File.join(CONFIGURATION_PATH, 'storage', 'rsync')
      autoload :Local,      File.join(CONFIGURATION_PATH, 'storage', 'local')
    end

    module Syncer
      autoload :RSync, File.join(CONFIGURATION_PATH, 'syncer', 'rsync')
      autoload :S3,    File.join(CONFIGURATION_PATH, 'syncer', 's3')
    end

    module Database
      autoload :Base,       File.join(CONFIGURATION_PATH, 'database', 'base')
      autoload :MySQL,      File.join(CONFIGURATION_PATH, 'database', 'mysql')
      autoload :PostgreSQL, File.join(CONFIGURATION_PATH, 'database', 'postgresql')
      autoload :MongoDB,    File.join(CONFIGURATION_PATH, 'database', 'mongodb')
      autoload :Redis,      File.join(CONFIGURATION_PATH, 'database', 'redis')
      autoload :Riak,      File.join(CONFIGURATION_PATH, 'database', 'riak')
    end
  end

  ##
  # Autoload exception classes
  module Exception
    autoload :CommandNotFound, File.join(EXCEPTION_PATH, 'command_not_found')
    autoload :CommandFailed,   File.join(EXCEPTION_PATH, 'command_failed')
  end

  ##
  # Dynamically defines all the available database, storage, compressor, encryptor and notifier
  # classes inside Backup::Finder to improve the DSL for the configuration file
  (DATABASES + STORAGES + COMPRESSORS + ENCRYPTORS + NOTIFIERS + SYNCERS).each do |constant|
    unless Backup::Finder.const_defined?(constant)
      Backup::Finder.const_set(constant, Class.new)
    end
  end
end
