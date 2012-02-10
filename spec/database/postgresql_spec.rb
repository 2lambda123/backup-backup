# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

describe Backup::Database::PostgreSQL do
  let(:model) { Backup::Model.new('foo', 'foo') }
  let(:db) do
    Backup::Database::PostgreSQL.new(model) do |db|
      db.name      = 'mydatabase'
      db.username  = 'someuser'
      db.password  = 'secret'
      db.host      = 'localhost'
      db.port      = '123'
      db.socket    = '/pgsql.sock'

      db.skip_tables = ['logs', 'profiles']
      db.only_tables = ['users', 'pirates']
      db.additional_options = ['--single-transaction', '--quick']
      db.pg_dump_utility    = '/path/to/pg_dump'
    end
  end

  describe '#initialize' do
    it 'should read the adapter details correctly' do
      db.name.should      == 'mydatabase'
      db.username.should  == 'someuser'
      db.password.should  == 'secret'
      db.host.should      == 'localhost'
      db.port.should      == '123'
      db.socket.should    == '/pgsql.sock'

      db.skip_tables.should == ['logs', 'profiles']
      db.only_tables.should == ['users', 'pirates']
      db.additional_options.should == ['--single-transaction', '--quick']
      db.pg_dump_utility.should    == '/path/to/pg_dump'
    end

    context 'when options are not set' do
      before do
        Backup::Database::PostgreSQL.any_instance.expects(:utility).
            with(:pg_dump).returns('/real/pg_dump')
      end

      it 'should use default values' do
        db = Backup::Database::PostgreSQL.new(model)

        db.name.should      be_nil
        db.username.should  be_nil
        db.password.should  be_nil
        db.host.should      be_nil
        db.port.should      be_nil
        db.socket.should    be_nil

        db.skip_tables.should         == []
        db.only_tables.should         == []
        db.additional_options.should  == []
        db.pg_dump_utility.should     == '/real/pg_dump'
      end
    end

    context 'when configuration defaults have been set' do
      after { Backup::Configuration::Database::PostgreSQL.clear_defaults! }

      it 'should use configuration defaults' do
        Backup::Configuration::Database::PostgreSQL.defaults do |db|
          db.name       = 'db_name'
          db.username   = 'db_username'
          db.password   = 'db_password'
          db.host       = 'db_host'
          db.port       = 789
          db.socket     = '/foo.sock'

          db.skip_tables = ['skip', 'tables']
          db.only_tables = ['only', 'tables']
          db.additional_options = ['--add', '--opts']
          db.pg_dump_utility    = '/default/path/to/pg_dump'
        end

        db = Backup::Database::PostgreSQL.new(model)
        db.name.should      == 'db_name'
        db.username.should  == 'db_username'
        db.password.should  == 'db_password'
        db.host.should      == 'db_host'
        db.port.should      == 789
        db.socket.should    == '/foo.sock'

        db.skip_tables.should         == ['skip', 'tables']
        db.only_tables.should         == ['only', 'tables']
        db.additional_options.should  == ['--add', '--opts']
        db.pg_dump_utility.should     == '/default/path/to/pg_dump'
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

      db.stubs(:pgdump).returns('pgdump_command')
    end

    context 'when no compressor is configured' do
      before do
        model.expects(:compressor).in_sequence(s).returns(nil)
      end

      it 'should run pgdump without compression' do
        db.expects(:run).in_sequence(s).with(
          "pgdump_command > '/dump/path/mydatabase.sql'"
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

      it 'should run pgdump with compression' do
        db.expects(:run).in_sequence(s).with(
          "pgdump_command | gzip > '/dump/path/mydatabase.sql.gz'"
        )
        db.perform!
      end
    end

  end # describe '#perform!'

  describe '#pgdump' do
    it 'should return the pgdump command string' do
      db.send(:pgdump).should ==
        "PGPASSWORD='secret' /path/to/pg_dump --username='someuser' " +
        "--host='localhost' --port='123' --host='/pgsql.sock' " +
        "--single-transaction --quick --table='users' --table='pirates' " +
        "--exclude-table='logs' --exclude-table='profiles' mydatabase"
    end

    context 'without a password' do
      before { db.password = nil }
      it 'should not leave a preceeding space' do
        db.send(:pgdump).should ==
          "/path/to/pg_dump --username='someuser' " +
          "--host='localhost' --port='123' --host='/pgsql.sock' " +
          "--single-transaction --quick --table='users' --table='pirates' " +
          "--exclude-table='logs' --exclude-table='profiles' mydatabase"
      end
    end
  end

  describe '#password_options' do
    it 'returns the environment variable set for the password' do
      db.send(:password_options).should == "PGPASSWORD='secret' "
    end

    context 'when password is not set' do
      before { db.password = nil }
      it 'should return an empty string' do
        db.send(:password_options).should == ''
      end
    end
  end

  describe '#username_options' do
    it 'should return the postgresql syntax for the username options' do
      db.send(:username_options).should == "--username='someuser'"
    end

    context 'when username is not set' do
      before { db.username = nil }
      it 'should return an empty string' do
        db.send(:username_options).should == ''
      end
    end
  end

  describe '#connectivity_options' do
    it 'should return the postgresql syntax for the connectivity options' do
      db.send(:connectivity_options).should ==
        "--host='localhost' --port='123' --host='/pgsql.sock'"
    end

    context 'when only the socket is set' do
      before do
        db.host   = ''
        db.port   = nil
      end

      it 'should return only the socket' do
        db.send(:connectivity_options).should == "--host='/pgsql.sock'"
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

  describe '#tables_to_dump' do
    it 'should return a string for the pg_dump selected table to dump option' do
      db.send(:tables_to_dump).should == "--table='users' --table='pirates'"
    end

    context 'when #only_tables is not set' do
      before { db.only_tables = [] }
      it 'should return an empty string' do
        db.send(:tables_to_dump).should == ''
      end
    end
  end

  describe '#tables_to_skip' do
    it 'should return a string for the pg_dump --ignore-tables option' do
      db.send(:tables_to_skip).should == "--exclude-table='logs' --exclude-table='profiles'"
    end

    context 'when #skip_tables is not set' do
      before { db.skip_tables = [] }
      it 'should return an empty string' do
        db.send(:tables_to_skip).should == ''
      end
    end
  end

end
