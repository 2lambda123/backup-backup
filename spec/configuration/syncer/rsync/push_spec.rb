# encoding: utf-8

require File.expand_path('../../../../spec_helper.rb', __FILE__)

describe Backup::Configuration::Syncer::RSync::Push do
  before do
    Backup::Configuration::Syncer::RSync::Push.defaults do |rsync|
      rsync.username  = 'my_username'
      rsync.password  = 'my_password'
      rsync.ip        = '123.45.678.90'
      rsync.port      = 22
      rsync.compress  = true
    end
  end
  after { Backup::Configuration::Syncer::RSync::Push.clear_defaults! }

  it 'should be a subclass of RSync::Base' do
    rsync = Backup::Configuration::Syncer::RSync::Push
    rsync.superclass.should == Backup::Configuration::Syncer::RSync::Base
  end

  it 'should set the default rsync configuration' do
    rsync = Backup::Configuration::Syncer::RSync::Push
    rsync.username.should  == 'my_username'
    rsync.password.should  == 'my_password'
    rsync.ip.should        == '123.45.678.90'
    rsync.port.should      == 22
    rsync.compress.should  == true
  end

  describe '#clear_defaults!' do
    it 'should clear all the defaults, resetting them to nil' do
      Backup::Configuration::Syncer::RSync::Push.clear_defaults!

      rsync = Backup::Configuration::Syncer::RSync::Push
      rsync.username.should  == nil
      rsync.password.should  == nil
      rsync.ip.should        == nil
      rsync.port.should      == nil
      rsync.compress.should  == nil
    end
  end
end
