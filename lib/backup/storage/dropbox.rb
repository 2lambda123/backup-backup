# encoding: utf-8

##
# Only load the Dropbox gem when the Backup::Storage::Dropbox class is loaded
Backup::Dependency.load('dropbox')

##
# Only load the timeout library when the Backup::Storage::Dropbox class is loaded
require 'timeout'

module Backup
  module Storage
    class Dropbox < Base

      ##
      # Dropbox API credentials
      attr_accessor :api_key, :api_secret

      ##
      # Path to where the backups will be stored
      attr_accessor :path

      ##
      # Dropbox connection timeout
      attr_accessor :timeout

      ##
      # Creates a new instance of the Dropbox storage object
      # First it sets the defaults (if any exist) and then evaluates
      # the configuration block which may overwrite these defaults
      def initialize(&block)
        load_defaults!(:except => ['password', 'email'])

        @path ||= 'backups'

        instance_eval(&block) if block_given?

        @timeout ||= 300
        @time = TIME
      end

      ##
      # This is the remote path to where the backup files will be stored
      def remote_path
        File.join(path, TRIGGER)
      end

      ##
      # Performs the backup transfer
      def perform!
        transfer!
        cycle!
      end

      private

      ##
      # The initial connection to Dropbox will provide the user with an authorization url.
      # The user must open this URL and confirm that the authorization successfully took place.
      # If this is the case, then the user hits 'enter' and the session will be properly established.
      # Immediately after establishing the session, the session will be serialized and written to a cache file
      # in Backup::CACHE_PATH. The cached file will be used from that point on to re-establish a connection with
      # Dropbox at a later time. This allows the user to avoid having to go to a new Dropbox URL to authorize over and over again.
      def connection
        if cache_exists?
          begin
            cached_session = ::Dropbox::Session.deserialize(File.read(cached_file))
            if cached_session.authorized?
              Logger.message "Session data loaded from cache!"
              return cached_session
            end
          rescue ArgumentError => error
            Logger.warn "Could not read session data from cache. Cache data might be corrupt."
          end
        end

        Logger.message "Creating a new session!"
        create_write_and_return_new_session!
      end

      ##
      # Transfers the archived file to the specified Dropbox folder
      def transfer!
        split!
        local_chunks.each do |chunk|
          Logger.message("#{ self.class } started transferring \"#{ File.basename(chunk) }\".")
          connection.upload(chunk, remote_path, :timeout => timeout)
        end
      end

      ##
      # Removes the transferred archive file from the Dropbox folder
      def remove!
        remote_chunks.each do |chunk|
          begin
            connection.delete(chunk)
          rescue ::Dropbox::FileNotFoundError
            Logger.warn "File \"#{ chunk }\" does not exist, skipping removal."
          end
        end
      end

      ##
      # Create a new session, write a serialized version of it to the
      # .cache directory, and return the session object
      def create_write_and_return_new_session!
        session = ::Dropbox::Session.new(api_key, api_secret)
        session.mode = :dropbox
        Logger.message "Open the following URL in a browser to authorize a session for your Dropbox account:"
        Logger.message ""
        Logger.message "\s\s#{session.authorize_url}"
        Logger.message ""
        Logger.message "Once Dropbox says you're authorized, hit enter to proceed."
        Timeout::timeout(180) { STDIN.gets }
        begin
          session.authorize
        rescue OAuth::Unauthorized => error
          Logger.error "Authorization failed!"
          raise error
        end
        Logger.message "Authorized!"

        Logger.message "Caching session data to file: #{cached_file}.."
        write_cache!(session)
        Logger.message "Cache data written! You will no longer need to manually authorize this Dropbox account via an URL on this machine."
        Logger.message "Note: If you run Backup with this Dropbox account on other machines, you will need to either authorize them the same way,"
        Logger.message "\s\sor simply copy over #{cached_file} to the cache directory"
        Logger.message "\s\son your other machines to use this Dropbox account there as well."

        session
      end

      ##
      # Returns the path to the cached file
      def cached_file
        File.join(Backup::CACHE_PATH, "#{api_key + api_secret}")
      end

      ##
      # Checks to see if the cache file exists
      def cache_exists?
        File.exist?(cached_file)
      end

      ##
      # Serializes and writes the Dropbox session to a cache file
      def write_cache!(session)
        File.open(cached_file, "w") do |cache_file|
          cache_file.write(session.serialize)
        end
      end

      public # DEPRECATED METHODS #############################################

      def email
        Logger.warn "[DEPRECATED] Backup::Storage::Dropbox.email is deprecated and will be removed at some point."
      end

      def email=(value)
        Logger.warn "[DEPRECATED] Backup::Storage::Dropbox.email= is deprecated and will be removed at some point."
      end

      def password
        Logger.warn "[DEPRECATED] Backup::Storage::Dropbox.password is deprecated and will be removed at some point."
      end

      def password=(value)
        Logger.warn "[DEPRECATED] Backup::Storage::Dropbox.password= is deprecated and will be removed at some point."
      end

    end
  end
end
