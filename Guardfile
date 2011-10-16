##
# To run the test suite against all 3 rubies: 1.9.2, 1.8.7 and REE, simply run the following command:
# $ guard start
#
# Be use you are using RVM and have Ruby 1.9.2, 1.8.7 and REE installed as well as all
# Backup's gem dependencies for each of these Ruby intepreters.

guard 'rspec',
  :version => 2,
  :rvm     => ['1.9.3@backupgem', '1.9.2@backupgem', '1.8.7@backupgem', 'ree@backupgem'],
  :bundler => true,
  :cli     => '--color --format Fuubar' do

  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { 'spec' }
  watch('spec/spec_helper.rb') { 'spec' }
end
