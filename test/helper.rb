require 'rubygems'
require 'test/unit'
require 'contest'
require 'rack/test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fixtures/exampleapp/app'

class Test::Unit::TestCase
  include Rack::Test::Methods
end
