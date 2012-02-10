# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

describe Backup::Configuration::Helpers do

  before do
    class Backup::Configuration::Base
      class << self
        attr_accessor :rspec_method, :rspec_test, :rspec_mocha
      end
    end
  end

  it 'should clear the defaults' do
    Backup::Configuration::Base.expects(:send).with('rspec_method=', nil)
    Backup::Configuration::Base.expects(:send).with('rspec_test=', nil)
    Backup::Configuration::Base.expects(:send).with('rspec_mocha=', nil)
    Backup::Configuration::Base.clear_defaults!
  end

  it 'should return the setters' do
    Backup::Configuration::Base.send(:setter_methods).count.should == 3
    %w[rspec_method= rspec_test= rspec_mocha=].each do |method|
      Backup::Configuration::Base.send(:setter_methods).should include(method)
    end
  end

  it 'should return the getters' do
    Backup::Configuration::Base.send(:getter_methods).count.should == 3
    %w[rspec_method rspec_test rspec_mocha].each do |method|
      Backup::Configuration::Base.send(:getter_methods).should include(method)
    end
  end
end
