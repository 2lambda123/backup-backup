# encoding: utf-8

module Backup
  module Encryptor
    class OpenSSL < Base

      ##
      # The password that'll be used to encrypt the backup. This
      # password will be required to decrypt the backup later on.
      attr_accessor :password
      
      ##
      # The password file to use to encrypt the backup. 
      attr_accessor :password_file

      ##
      # Determines whether the 'base64' should be used or not
      attr_writer :base64

      ##
      # Determines whether the 'salt' flag should be used
      attr_writer :salt

      ##
      # Creates a new instance of Backup::Encryptor::OpenSSL and
      # sets the password attribute to what was provided
      def initialize(&block)
        load_defaults!

        @base64 ||= false
        @salt   ||= false
        @password_file ||= nil

        instance_eval(&block) if block_given?
      end

      ##
      # Performs the encryption of the backup file
      def perform!
        log!
        run("#{ utility(:openssl) } #{ options } -in '#{ Backup::Model.file }' -out '#{ Backup::Model.file }.enc'")
        rm(Backup::Model.file)
        Backup::Model.extension += '.enc'
      end

    private

      ##
      # Backup::Encryptor::OpenSSL uses the 256bit AES encryption cipher.
      # 256bit AES is what the US Government uses to encrypt information at the "Top Secret" level.
      def options
        (['aes-256-cbc'] + base64 + salt + pass).join("\s")
      end

      ##
      # Returns '-base64' if @base64 is set to 'true'.
      # This option will make the encrypted output base64 encoded,
      # this makes the encrypted file readable using text editors
      def base64
        return ['-base64'] if @base64; []
      end

      ##
      # Returns '-salt' if @salt is set to 'true'.
      # This options adds strength to the encryption
      def salt
        return ['-salt'] if @salt; []
      end
      
      ##
      # Returns '-pass file:<password file>' when @password_file has been set.
      def pass
        if @password_file
          ["-pass file:#{@password_file}"]
        else
          ["-k '#{@password}'"]
        end
      end

    end
  end
end
