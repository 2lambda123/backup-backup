# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

describe Backup::Database::MySQL do
  let(:model) { Backup::Model.new('foo', 'foo') }
  let(:db) do
    Backup::Database::MySQL.new(model) do |db|
      db.name      = 'mydatabase'
      db.username  = 'someuser'
      db.password  = 'secret'
      db.host      = 'localhost'
      db.port      = '123'
      db.socket    = '/mysql.sock'

      db.skip_tables = ['logs', 'profiles']
      db.only_tables = ['users', 'pirates']
      db.additional_options = ['--single-transaction', '--quick']
      db.mysqldump_utility  = '/path/to/mysqldump'
    end
  end

  describe '#initialize' do
    it 'should read the adapter details correctly' do
      db.name.should      == 'mydatabase'
      db.username.should  == 'someuser'
      db.password.should  == 'secret'
      db.host.should      == 'localhost'
      db.port.should      == '123'
      db.socket.should    == '/mysql.sock'

      db.skip_tables.should == ['logs', 'profiles']
      db.only_tables.should == ['users', 'pirates']
      db.additional_options.should == ['--single-transaction', '--quick']
      db.mysqldump_utility.should  == '/path/to/mysqldump'
    end

    context 'when options are not set' do
      before do
        Backup::Database::MySQL.any_instance.expects(:utility).
            with(:mysqldump).returns('/real/mysqldump')
      end

      it 'should use default values' do
        db = Backup::Database::MySQL.new(model)

        db.name.should      == :all
        db.username.should  be_nil
        db.password.should  be_nil
        db.host.should      be_nil
        db.port.should      be_nil
        db.socket.should    be_nil

        db.skip_tables.should         == []
        db.only_tables.should         == []
        db.additional_options.should  == []
        db.mysqldump_utility.should  == '/real/mysqldump'
      end
    end

    context 'when configuration defaults have been set' do
      after { Backup::Configuration::Database::MySQL.clear_defaults! }

      it 'should use configuration defaults' do
        Backup::Configuration::Database::MySQL.defaults do |db|
          db.name       = 'db_name'
          db.username   = 'db_username'
          db.password   = 'db_password'
          db.host       = 'db_host'
          db.port       = 789
          db.socket     = '/foo.sock'

          db.skip_tables = ['skip', 'tables']
          db.only_tables = ['only', 'tables']
          db.additional_options = ['--add', '--opts']
          db.mysqldump_utility  = '/default/path/to/mysqldump'
        end

        db = Backup::Database::MySQL.new(model)
        db.name.should      == 'db_name'
        db.username.should  == 'db_username'
        db.password.should  == 'db_password'
        db.host.should      == 'db_host'
        db.port.should      == 789
        db.socket.should    == '/foo.sock'

        db.skip_tables.should         == ['skip', 'tables']
        db.only_tables.should         == ['only', 'tables']
        db.additional_options.should  == ['--add', '--opts']
        db.mysqldump_utility.should   == '/default/path/to/mysqldump'
      end
    end
  end # describe '#initialize'

  describe '#perform!' do
    let(:s) { sequence '' }
    before do
      # superclass actions
      db.expects(:prepare!).in_sequence(s)
      db.expects(:log!).in_sequence(s)
      db.instance_variable_set(:@dump_path, '/dump/path')

      db.stubs(:mysqldump).returns('mysqldump_command')
      db.stubs(:dump_filename).returns('dump_filename')
    end

    context 'when no compressor is configured' do
      before do
        model.expects(:compressor).in_sequence(s).returns(nil)
      end

      it 'should run mysqldump without compression' do
        db.expects(:run).in_sequence(s).with(
          "mysqldump_command > '/dump/path/dump_filename.sql'"
        )
        db.perform!
      end
    end

    context 'when a compressor is configured' do
      before do
        compressor = mock
        model.expects(:compressor).twice.in_sequence(s).returns(compressor)
        compressor.expects(:compress_with).in_sequence(s).yields('gzip', '.gz')
      end

      it 'should run mysqldump with compression' do
        db.expects(:run).in_sequence(s).with(
          "mysqldump_command | gzip > '/dump/path/dump_filename.sql.gz'"
        )
        db.perform!
      end
    end

  end # describe '#perform!'

  describe '#mysqldump' do
    before do
      db.stubs(:mysqldump_utility).returns(:mysqldump_utility)
      db.stubs(:credential_options).returns(:credential_options)
      db.stubs(:connectivity_options).returns(:connectivity_options)
      db.stubs(:user_options).returns(:user_options)
      db.stubs(:db_name).returns(:db_name)
      db.stubs(:tables_to_dump).returns(:tables_to_dump)
      db.stubs(:tables_to_skip).returns(:tables_to_skip)
    end

    it 'should return the mysqldump command string' do
      db.send(:mysqldump).should ==
        "mysqldump_utility credential_options connectivity_options " +
        "user_options db_name tables_to_dump tables_to_skip"
    end
  end

  describe '#dump_filename' do
    context 'when @name is set to :all' do
      before { db.name = :all }
      it 'should set the filename to "all-databases"' do
        db.send(:dump_filename).should == 'all-databases'
      end
    end

    context 'when @name is not set to :all' do
      it 'should return @name' do
        db.send(:dump_filename).should == 'mydatabase'
      end
    end
  end

  describe '#credential_options' do
    context 'when a password is set' do
      it 'should return the command string for the user credentials' do
        db.send(:credential_options).should ==
          "--user='someuser' --password='secret'"
      end
    end

    context 'when no password is set' do
      before { db.password = nil }
      it 'should return the command string for the user credentials' do
        db.send(:credential_options).should ==
          "--user='someuser'"
      end
    end
  end

  describe '#connectivity_options' do
    it 'should return the mysql syntax for the connectivity options' do
      db.send(:connectivity_options).should ==
        "--host='localhost' --port='123' --socket='/mysql.sock'"
    end

    context 'when only the socket is set' do
      it 'should return only the socket' do
        db.host   = ''
        db.port   = nil
        db.send(:connectivity_options).should == "--socket='/mysql.sock'"
      end
    end

    context 'when only the host and port are set' do
      it 'should return only the host and port' do
        db.socket = nil
        db.send(:connectivity_options).should ==
          "--host='localhost' --port='123'"
      end
    end
  end

  describe '#user_options' do
    it 'should return a string of additional options specified by the user' do
      db.send(:user_options).should == '--single-transaction --quick'
    end

    context 'when #additional_options is not set' do
      before { db.additional_options = [] }
      it 'should return an empty string' do
        db.send(:user_options).should == ''
      end
    end
  end

  describe '#db_name' do
    context 'when @name is set to :all' do
      before { db.name = :all }
      it 'should return the mysqldump flag to dump all databases' do
        db.send(:db_name).should == '--all-databases'
      end
    end

    context 'when @name is not set to :all' do
      it 'should return @name' do
        db.send(:db_name).should == 'mydatabase'
      end
    end
  end

  describe '#tables_to_dump' do
    it 'should return a string for the mysqldump selected table to dump option' do
      db.send(:tables_to_dump).should == 'users pirates'
    end

    context 'when #only_tables is not set' do
      before { db.only_tables = [] }
      it 'should return an empty string' do
        db.send(:tables_to_dump).should == ''
      end
    end

    context 'when dump_all? is true' do
      before { db.stubs(:dump_all?).returns(true) }
      it 'should return nil' do
        db.send(:tables_to_dump).should be_nil
      end
    end
  end

  describe '#tables_to_skip' do
    it 'should return a string for the mysqldump --ignore-tables option' do
      db.send(:tables_to_skip).should ==
        "--ignore-table='mydatabase.logs' --ignore-table='mydatabase.profiles'"
    end

    context 'when #skip_tables is not set' do
      before { db.skip_tables = [] }
      it 'should return an empty string' do
        db.send(:tables_to_skip).should == ''
      end
    end

    context 'when dump_all? is true' do
      before { db.stubs(:dump_all?).returns(true) }
      it 'should return nil' do
        db.send(:tables_to_skip).should be_nil
      end
    end
  end

  describe '#dump_all?' do
    context 'when @name is set to :all' do
      before { db.name = :all }
      it 'should return true' do
        db.send(:dump_all?).should be_true
      end
    end

    context 'when @name is not set to :all' do
      it 'should return false' do
        db.send(:dump_all?).should be_false
      end
    end
  end
end
