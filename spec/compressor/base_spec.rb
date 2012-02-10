# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

describe Backup::Compressor::Base do
  let(:base) { Backup::Compressor::Base.new }

  describe '#initialize' do
    it 'should load defaults' do
      Backup::Compressor::Base.any_instance.expects(:load_defaults!)
      base
    end
  end

  describe '#compressor_name' do
    it 'should return class name with Backup namespace removed' do
      base.send(:compressor_name).should == 'Compressor::Base'
    end
  end

  describe '#log!' do
    it 'should log a message' do
      base.expects(:compressor_name).returns('Compressor Name')
      Backup::Logger.expects(:message).with(
        'Using Compressor Name for compression.'
      )
      base.send(:log!)
    end
  end

end
