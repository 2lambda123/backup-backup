# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

##
# available S3 regions:
# eu-west-1, us-east-1, ap-southeast-1, us-west-1
describe Backup::Storage::S3 do

  let(:s3) do
    Backup::Storage::S3.new do |s3|
      s3.access_key_id      = 'my_access_key_id'
      s3.secret_access_key  = 'my_secret_access_key'
      s3.region             = 'us-east-1'
      s3.bucket             = 'my-bucket'
      s3.path               = 'backups'
      s3.keep               = 20
    end
  end

  before do
    Backup::Configuration::Storage::S3.clear_defaults!
  end

  it 'should have defined the configuration properly' do
    s3.access_key_id.should      == 'my_access_key_id'
    s3.secret_access_key.should  == 'my_secret_access_key'
    s3.region.should             == 'us-east-1'
    s3.bucket.should             == 'my-bucket'
    s3.keep.should               == 20
  end

  it 'should use the defaults if a particular attribute has not been defined' do
    Backup::Configuration::Storage::S3.defaults do |s3|
      s3.access_key_id = 'my_access_key_id'
      s3.region        = 'us-east-1'
      s3.keep          = 500
    end

    s3 = Backup::Storage::S3.new do |s3|
      s3.region = 'us-west-1'
      s3.path   = 'my/backups'
    end

    s3.access_key_id.should     == 'my_access_key_id' # not defined, uses default
    s3.secret_access_key.should == nil                # not defined, no default
    s3.region.should            == 'us-west-1'        # defined, overwrites default
    s3.bucket.should            == nil                # not defined, no default
    s3.path.should              == 'my/backups'       # overwritten from Backup::Storage::S3
    s3.keep.should              == 500                # comes from the default configuration
  end

  describe '#connection' do
    it 'should establish a connection to Amazon S3 using the provided credentials' do
      Fog::Storage.expects(:new).with({
        :provider               => 'AWS',
        :aws_access_key_id      => 'my_access_key_id',
        :aws_secret_access_key  => 'my_secret_access_key',
        :region                 => 'us-east-1'
      })

      s3.send(:connection)
    end
  end

  describe '#provider' do
    it 'should be AWS' do
      s3.provider == 'AWS'
    end
  end

  describe '#transfer!' do
    let(:connection) { mock('Fog::Storage') }
    before do
      Fog::Storage.stubs(:new).returns(connection)
    end

    it 'should transfer the provided file to the bucket' do
      Backup::Model.new('blah', 'blah') {}
      file = mock("Backup::Storage::S3::File")
      File.expects(:open).with("#{File.join(Backup::TMP_PATH, "#{ Backup::TIME }.#{ Backup::TRIGGER}")}.tar").returns(file)
      s3.expects(:remote_file).returns("#{ Backup::TIME }.#{ Backup::TRIGGER }.tar")
      connection.expects(:sync_clock)
      connection.expects(:put_object).with('my-bucket', "backups/myapp/#{ Backup::TIME }.#{ Backup::TRIGGER }.tar", file)
      s3.send(:transfer!)
    end

    it 'should transfer the provided file chunks to the bucket' do
      s3.split_archive_file = true
      s3.archive_file_chunk_size = 100
      File.expects(:size?).with(File.join(Backup::TMP_PATH, "#{ Backup::TIME }.#{ Backup::TRIGGER }.tar")).returns(130 * 1000 * 1000)
      s3.expects(:run).once

      Backup::Model.new('blah', 'blah') {}
      file = mock("Backup::Storage::S3::File")
      File.expects(:open).with("#{File.join(Backup::TMP_PATH, "#{ Backup::TIME }.#{ Backup::TRIGGER}")}.tar-00").returns(file)
      File.expects(:open).with("#{File.join(Backup::TMP_PATH, "#{ Backup::TIME }.#{ Backup::TRIGGER}")}.tar-01").returns(file)
      s3.expects(:remote_file).returns("#{ Backup::TIME }.#{ Backup::TRIGGER }.tar").twice
      connection.expects(:sync_clock)
      connection.expects(:put_object).with('my-bucket', "backups/myapp/#{ Backup::TIME }.#{ Backup::TRIGGER }.tar-00", file)
      connection.expects(:put_object).with('my-bucket', "backups/myapp/#{ Backup::TIME }.#{ Backup::TRIGGER }.tar-01", file)
      s3.send(:transfer!)
    end
  end

  describe '#remove!' do
    let(:connection) { mock('Fog::Storage') }
    before do
      Fog::Storage.stubs(:new).returns(connection)
    end

    it 'should remove the file from the bucket' do
      s3.expects(:remote_file).returns("#{ Backup::TIME }.#{ Backup::TRIGGER }.tar")
      connection.expects(:sync_clock)
      connection.expects(:delete_object).with('my-bucket', "backups/myapp/#{ Backup::TIME }.#{ Backup::TRIGGER }.tar")
      s3.send(:remove!)
    end

    it 'should remove the file chunks from the bucket' do
      s3.split_archive_file = true
      s3.archive_file_chunk_size = 100
      s3.number_of_archive_chunks = 2

      s3.expects(:remote_file).returns("#{ Backup::TIME }.#{ Backup::TRIGGER }.tar").twice
      connection.expects(:sync_clock)
      connection.expects(:delete_object).with('my-bucket', "backups/myapp/#{ Backup::TIME }.#{ Backup::TRIGGER }.tar-00")
      connection.expects(:delete_object).with('my-bucket', "backups/myapp/#{ Backup::TIME }.#{ Backup::TRIGGER }.tar-01")
      s3.send(:remove!)
    end
  end

  describe '#perform' do
    it 'should invoke transfer! and cycle!' do
      s3.expects(:transfer!)
      s3.expects(:cycle!)
      s3.perform!
    end
  end

end
