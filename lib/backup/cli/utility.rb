# encoding: utf-8

##
# Build the Backup Command Line Interface using Thor
module Backup
  module CLI
    class Utility < Thor
      include Thor::Actions

      ##
      # [Perform]
      # Performs the backup process. The only required option is the --trigger [-t].
      # If the other options (--config-file, --data-path, --cache--path, --tmp-path) aren't specified
      # it'll fallback to the (good) defaults
      method_option :trigger,         :type => :string,  :aliases => ['-t', '--triggers'], :required => true
      method_option :config_file,     :type => :string,  :aliases => '-c'
      method_option :data_path,       :type => :string,  :aliases => '-d'
      method_option :log_path,        :type => :string,  :aliases => '-l'
      method_option :cache_path,      :type => :string
      method_option :tmp_path,        :type => :string
      method_option :quiet,           :type => :boolean, :aliases => '-q'
      method_option :silence_warning, :type => :boolean
      desc 'perform', "Performs the backup for the specified trigger.\n" +
                      "You may perform multiple backups by providing multiple triggers, separated by commas.\n\n" +
                      "Example:\n\s\s$ backup perform --triggers backup1,backup2,backup3,backup4\n\n" +
                      "This will invoke 4 backups, and they will run in the order specified (not asynchronous)."
      def perform
        ##
        # Overwrites the CONFIG_FILE location, if --config-file was specified
        if options[:config_file]
          Backup.send(:remove_const, :CONFIG_FILE)
          Backup.send(:const_set, :CONFIG_FILE, options[:config_file])
        end

        ##
        # Overwrites the DATA_PATH location, if --data-path was specified
        if options[:data_path]
          Backup.send(:remove_const, :DATA_PATH)
          Backup.send(:const_set, :DATA_PATH, options[:data_path])
        end

        ##
        # Overwrites the LOG_PATH location, if --log-path was specified
        if options[:log_path]
          Backup.send(:remove_const, :LOG_PATH)
          Backup.send(:const_set, :LOG_PATH, options[:log_path])
        end

        ##
        # Overwrites the CACHE_PATH location, if --cache-path was specified
        if options[:cache_path]
          Backup.send(:remove_const, :CACHE_PATH)
          Backup.send(:const_set, :CACHE_PATH, options[:cache_path])
        end

        ##
        # Overwrites the TMP_PATH location, if --tmp-path was specified
        if options[:tmp_path]
          Backup.send(:remove_const, :TMP_PATH)
          Backup.send(:const_set, :TMP_PATH, options[:tmp_path])
        end

        ##
        # Silence Backup::Logger from printing to STDOUT, if --quiet was specified
        if options[:quiet]
          Backup::Logger.send(:const_set, :QUIET, options[:quiet])
        end

        ##
        # Ensure the CACHE_PATH, TMP_PATH and LOG_PATH are created if they do not yet exist
        Array.new([Backup::CACHE_PATH, Backup::TMP_PATH, Backup::LOG_PATH]).each do |path|
          FileUtils.mkdir_p(path)
        end

        if !options[:silence_warning]
          puts "-"*120
          Backup::Logger.warn "Backup cycling changed in version 3.0.20 and is not backwards compatible with previous versions."
          Backup::Logger.warn "Visit: https://github.com/meskyanichi/backup/wiki/Splitter for more information"
          Backup::Logger.warn "Pass in --silence-warning to `backup perform` if you wish to remove this warning."
          puts "-"*120
        end

        ##
        # Prepare all trigger names by splitting them by ','
        # and finding trigger names matching wildcard
        triggers = options[:trigger].split(",")
        triggers.map!(&:strip).map!{ |t|
          t.include?(Backup::Finder::WILDCARD) ?
            Backup::Finder.new(t).matching : t
        }.flatten!

        ##
        # Process each trigger
        triggers.each do |trigger|

          ##
          # Defines the TRIGGER constant
          Backup.send(:const_set, :TRIGGER, trigger)

          ##
          # Define the TIME constants
          Backup.send(:const_set, :TIME, Time.now.strftime("%Y.%m.%d.%H.%M.%S"))

          ##
          # Ensure DATA_PATH and DATA_PATH/TRIGGER are created if they do not yet exist
          FileUtils.mkdir_p(File.join(Backup::DATA_PATH, Backup::TRIGGER))

          ##
          # Parses the backup configuration file and returns the model instance by trigger
          model = Backup::Finder.new(trigger).find

          ##
          # Runs the returned model
          Backup::Logger.message "Performing backup for #{model.label}!"
          model.perform!

          ##
          # Removes the TRIGGER constant
          Backup.send(:remove_const, :TRIGGER) if defined? Backup::TRIGGER

          ##
          # Removes the TIME constant
          Backup.send(:remove_const, :TIME) if defined? Backup::TIME

          ##
          # Reset the Backup::Model.current to nil for the next potential run
          Backup::Model.current = nil

          ##
          # Reset the Backup::Model.all to an empty array since this will be
          # re-filled during the next Backup::Finder.new(arg1, arg2).find
          Backup::Model.all = Array.new

          ##
          # Reset the Backup::Model.extension to 'tar' so it's at its
          # initial state when the next Backup::Model initializes
          Backup::Model.extension = 'tar'
        end
      end

      ##
      # [Generate]
      # Generates a configuration file based on the arguments passed in.
      # For example, running $ backup generate --databases='mongodb' will generate a pre-populated
      # configuration file with a base MongoDB setup
      desc 'generate:model', 'Generates a Backup model'
      method_option :name,        :type => :string, :required => true
      method_option :path,        :type => :string
      method_option :databases,   :type => :string
      method_option :storages,    :type => :string
      method_option :syncers,     :type => :string
      method_option :encryptors,  :type => :string
      method_option :compressors, :type => :string
      method_option :notifiers,   :type => :string
      method_option :archives,    :type => :boolean
      method_option :splitter,    :type => :boolean, :default => true, :desc => "use `--no-splitter` to disable"
      define_method "generate:model" do
        config_path = options[:path] || Backup::PATH
        models_path = File.join(config_path, "models")
        config      = File.join(config_path, "config.rb")
        model       = File.join(models_path, "#{options[:name]}.rb")

        temp_file = Tempfile.new('backup.rb')
        temp_file << "# encoding: utf-8\n\n##\n# Backup Generated: #{options[:name]}\n"
        temp_file << "# Once configured, you can run the backup with the following command:\n#\n"
        temp_file << "# $ backup perform -t #{options[:name]} [-c <path_to_configuration_file>]\n#\n"
        temp_file << "Backup::Model.new(:#{options[:name]}, 'Description for #{options[:name]}') do\n\n"

        if options[:splitter]
          temp_file << File.read( File.join(Backup::TEMPLATE_PATH, 'model', 'splitter') ) + "\n\n"
        end

        if options[:archives]
          temp_file << File.read( File.join(Backup::TEMPLATE_PATH, 'model', 'archive') ) + "\n\n"
        end

        [:databases, :storages, :syncers, :encryptors, :compressors, :notifiers].each do |item|
          if options[item]
            options[item].split(',').map(&:strip).uniq.each do |entry|
              if File.exist?( File.join(Backup::TEMPLATE_PATH, 'model', item.to_s[0..-2], entry) )
                temp_file << File.read( File.join(Backup::TEMPLATE_PATH, 'model', item.to_s[0..-2], entry) ) + "\n\n"
              end
            end
          end
        end

        temp_file << "end\n\n"
        temp_file.close

        if overwrite?(model)
          FileUtils.mkdir_p(models_path)
          File.open(model, 'w') do |file|
            file.write( File.read(temp_file.path) )
          end
          puts "Generated configuration file in '#{ model }'"
        end
        temp_file.unlink

        if not File.exist?(config)
          File.open(config, "w") do |file|
            file.write(File.read(File.join(Backup::TEMPLATE_PATH, 'model', "config")))
          end
          puts "Generated configuration file in '#{ config }'"
        end
      end

      desc 'generate:config', 'Generates the main Backup bootstrap/configuration file'
      method_option :path, :type => :string
      define_method 'generate:config' do
        config_path = options[:path] || Backup::PATH
        config      = File.join(config_path, "config.rb")

        if overwrite?(config)
          File.open(config, "w") do |file|
            file.write(File.read(File.join(Backup::TEMPLATE_PATH, 'model', "config")))
          end
          puts "Generated configuration file in '#{ config }'"
        end
      end

      ##
      # [Decrypt]
      # Shorthand for decrypting encrypted files
      desc 'decrypt', 'Decrypts encrypted files'
      method_option :encryptor, :type => :string,  :required => true
      method_option :in,        :type => :string,  :required => true
      method_option :out,       :type => :string,  :required => true
      method_option :base64,    :type => :boolean, :default  => false
      method_option :pass_file, :type => :string,  :default => ''
      method_option :salt,      :type => :boolean, :default => false
      def decrypt
        case options[:encryptor].downcase
        when 'openssl'
          base64 = options[:base64] ? '-base64' : ''
          pass   = options[:pass_file] ? "-pass file:#{options[:pass_file]}" : ''
          salt   = options[:salt] ? '-salt' : ''
          %x[openssl aes-256-cbc -d #{base64} #{pass} #{salt} -in '#{options[:in]}' -out '#{options[:out]}']
        when 'gpg'
          %x[gpg -o '#{options[:out]}' -d '#{options[:in]}']
        else
          puts "Unknown encryptor: #{options[:encryptor]}"
          puts "Use either 'openssl' or 'gpg'"
        end
      end

      ##
      # [Dependencies]
      # Returns a list of Backup's dependencies
      desc 'dependencies', 'Display the list of dependencies for Backup, or install them through Backup.'
      method_option :install, :type => :string
      method_option :list,    :type => :boolean
      def dependencies
        unless options.any?
          puts
          puts "To display a list of available dependencies, run:\n\n"
          puts "  backup dependencies --list"
          puts
          puts "To install one of these dependencies (with the correct version), run:\n\n"
          puts "  backup dependencies --install <name>"
          exit
        end

        if options[:list]
          Backup::Dependency.all.each do |name, gemspec|
            puts
            puts name
            puts "--------------------------------------------------"
            puts "version:       #{gemspec[:version]}"
            puts "lib required:  #{gemspec[:require]}"
            puts "used for:      #{gemspec[:for]}"
          end
        end

        if options[:install]
          puts
          puts "Installing \"#{options[:install]}\" version \"#{Backup::Dependency.all[options[:install]][:version]}\".."
          puts "If this doesn't work, please issue the following command yourself:\n\n"
          puts "  gem install #{options[:install]} -v '#{Backup::Dependency.all[options[:install]][:version]}'\n\n"
          puts "Please wait..\n\n"
          puts %x[gem install #{options[:install]} -v '#{Backup::Dependency.all[options[:install]][:version]}']
        end
      end

      ##
      # [Version]
      # Returns the current version of the Backup gem
      map '-v' => :version
      desc 'version', 'Display installed Backup version'
      def version
        puts "Backup #{Backup::Version.current}"
      end

    private

      ##
      # Helper method for asking the user if he/she wants to overwrite the file
      def overwrite?(path)
        if File.exist?(path)
          return yes? "A configuration file already exists in #{ path }. Do you want to overwrite? [y/n]"
        end
        true
      end

    end
  end
end
