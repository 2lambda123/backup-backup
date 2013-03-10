# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

describe Backup::Storage::OpenStack do
  let(:model)   { Backup::Model.new(:test_trigger, 'test label') }
  let(:storage) do
    Backup::Storage::OpenStack.new(model) do |cf|
      cf.username  = 'my_username'
      cf.api_key   = 'my_api_key'
      cf.auth_url  = 'lon.auth.api.rackspacecloud.com'
      cf.container = 'my_container'
      cf.keep      = 5
    end
  end

  it 'should be a subclass of Storage::Base' do
    Backup::Storage::OpenStack.
      superclass.should == Backup::Storage::Base
  end

  describe '#initialize' do
    after { Backup::Storage::OpenStack.clear_defaults! }

    it 'should load pre-configured defaults through Base' do
      Backup::Storage::OpenStack.any_instance.expects(:load_defaults!)
      storage
    end

    it 'should pass the model reference to Base' do
      storage.instance_variable_get(:@model).should == model
    end

    it 'should pass the storage_id to Base' do
      storage = Backup::Storage::OpenStack.new(model, 'my_storage_id')
      storage.storage_id.should == 'my_storage_id'
    end

    context 'when no pre-configured defaults have been set' do
      it 'should use the values given' do
        storage.username.should   == 'my_username'
        storage.api_key.should    == 'my_api_key'
        storage.auth_url.should   == 'lon.auth.api.rackspacecloud.com'
        storage.container.should  == 'my_container'
        storage.path.should       == 'backups'

        storage.storage_id.should be_nil
        storage.keep.should       == 5
      end

      it 'should use default values if none are given' do
        storage = Backup::Storage::OpenStack.new(model)

        storage.username.should   be_nil
        storage.api_key.should    be_nil
        storage.auth_url.should   be_nil
        storage.container.should  be_nil
        storage.path.should       == 'backups'

        storage.storage_id.should be_nil
        storage.keep.should       be_nil
      end
    end # context 'when no pre-configured defaults have been set'

    context 'when pre-configured defaults have been set' do
      before do
        Backup::Storage::OpenStack.defaults do |s|
          s.username   = 'some_username'
          s.api_key    = 'some_api_key'
          s.auth_url   = 'some_auth_url'
          s.container  = 'some_container'
          s.path       = 'some_path'
          s.keep       = 15
        end
      end

      it 'should use pre-configured defaults' do
        storage = Backup::Storage::OpenStack.new(model)

        storage.username.should   == 'some_username'
        storage.api_key.should    == 'some_api_key'
        storage.auth_url.should   == 'some_auth_url'
        storage.container.should  == 'some_container'
        storage.path.should       == 'some_path'

        storage.storage_id.should be_nil
        storage.keep.should       == 15
      end

      it 'should override pre-configured defaults' do
        storage = Backup::Storage::OpenStack.new(model) do |s|
          s.username   = 'new_username'
          s.api_key    = 'new_api_key'
          s.auth_url   = 'new_auth_url'
          s.container  = 'new_container'
          s.path       = 'new_path'
          s.keep       = 10
        end

        storage.username.should   == 'new_username'
        storage.api_key.should    == 'new_api_key'
        storage.auth_url.should   == 'new_auth_url'
        storage.container.should  == 'new_container'
        storage.path.should       == 'new_path'

        storage.storage_id.should be_nil
        storage.keep.should       == 10
      end
    end # context 'when pre-configured defaults have been set'
  end # describe '#initialize'

  describe '#provider' do
    it 'should set the Fog provider' do
      storage.send(:provider).should == 'OpenStack'
    end
  end

  describe '#connection' do
    let(:connection) { mock }

    it 'should create a new standard connection' do
      Fog::Storage.expects(:new).once.with(
        :provider             => 'OpenStack',
        :openstack_username   => 'my_username',
        :openstack_api_key    => 'my_api_key',
        :openstack_auth_url   => 'lon.auth.api.rackspacecloud.com'
      ).returns(connection)
      storage.send(:connection).should == connection
    end

    it 'should return an existing connection' do
      Fog::Storage.expects(:new).once.returns(connection)
      storage.send(:connection).should == connection
      storage.send(:connection).should == connection
    end

  end # describe '#connection'

  describe '#transfer!' do
    let(:connection) { mock }
    let(:package) { mock }
    let(:file) { mock }
    let(:s) { sequence '' }

    before do
      storage.instance_variable_set(:@package, package)
      storage.stubs(:storage_name).returns('Storage::OpenStack')
      storage.stubs(:local_path).returns('/local/path')
      storage.stubs(:connection).returns(connection)
    end

    it 'should transfer the package files' do
      storage.expects(:remote_path_for).in_sequence(s).with(package).
          returns('remote/path')
      storage.expects(:files_to_transfer_for).in_sequence(s).with(package).
        multiple_yields(
        ['2011.12.31.11.00.02.backup.tar.enc-aa', 'backup.tar.enc-aa'],
        ['2011.12.31.11.00.02.backup.tar.enc-ab', 'backup.tar.enc-ab']
      )
      # first yield
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::OpenStack started transferring " +
        "'2011.12.31.11.00.02.backup.tar.enc-aa'."
      )
      File.expects(:open).in_sequence(s).with(
        File.join('/local/path', '2011.12.31.11.00.02.backup.tar.enc-aa'), 'r'
      ).yields(file)
      connection.expects(:put_object).in_sequence(s).with(
        'my_container', File.join('remote/path', 'backup.tar.enc-aa'), file
      )
      # second yield
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::OpenStack started transferring " +
        "'2011.12.31.11.00.02.backup.tar.enc-ab'."
      )
      File.expects(:open).in_sequence(s).with(
        File.join('/local/path', '2011.12.31.11.00.02.backup.tar.enc-ab'), 'r'
      ).yields(file)
      connection.expects(:put_object).in_sequence(s).with(
        'my_container', File.join('remote/path', 'backup.tar.enc-ab'), file
      )

      storage.send(:transfer!)
    end
  end # describe '#transfer!'

  describe '#remove!' do
    let(:package) { mock }
    let(:connection) { mock }
    let(:s) { sequence '' }

    before do
      storage.stubs(:storage_name).returns('Storage::OpenStack')
      storage.stubs(:connection).returns(connection)
    end

    it 'should remove the package files' do
      storage.expects(:remote_path_for).in_sequence(s).with(package).
          returns('remote/path')
      storage.expects(:transferred_files_for).in_sequence(s).with(package).
        multiple_yields(
        ['2011.12.31.11.00.02.backup.tar.enc-aa', 'backup.tar.enc-aa'],
        ['2011.12.31.11.00.02.backup.tar.enc-ab', 'backup.tar.enc-ab']
      )
      # first yield
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::OpenStack started removing " +
        "'2011.12.31.11.00.02.backup.tar.enc-aa' " +
        "from container 'my_container'."
      )
      connection.expects(:delete_object).in_sequence(s).with(
        'my_container', File.join('remote/path', 'backup.tar.enc-aa')
      )
      # second yield
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::OpenStack started removing " +
        "'2011.12.31.11.00.02.backup.tar.enc-ab' " +
        "from container 'my_container'."
      )
      connection.expects(:delete_object).in_sequence(s).with(
        'my_container', File.join('remote/path', 'backup.tar.enc-ab')
      )

      storage.send(:remove!, package)
    end
  end # describe '#remove!'

end
