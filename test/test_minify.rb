require 'helper'

class TestMinify < Test::Unit::TestCase
  def app
    App
  end

  def output
    last_response.body
  end

  should "rock pants off" do
    get '/'
    assert_match "Hello", output
  end

  should "Include all scripts" do
    get '/foo'
    assert_match /\/js\/script-1.js\?/, output
    assert_match /\/js\/script-2.js\?/, output
  end
  
  describe "Package.all(:js)" do
    setup do
      @packages = Sinatra::Minify::Package.send(:all, :js, App)
    end
  
    should "have only one package" do
      assert_equal 1, @packages.size
    end

    should "return base as the only package" do
      assert_equal 'base', @packages.first.set
    end
  end

  describe "Package.all(:css)" do
    setup do
      @packages = Sinatra::Minify::Package.send(:all, :css, App)
    end
  
    should "have only one package" do
      assert_equal 1, @packages.size
    end

    should "return base as the only package" do
      assert_equal 'base', @packages.first.set
    end
  end

  describe "In a production environment" do
    def setup
      app.enable :force_minify
    end

    def teardown
      app.disable :force_minify
    end

    should "Include the minified script" do
      get '/foo'
      assert_match /\/js\/base.min.js\?/, output
    end
  end

  describe "Building files" do
    def setup
      Sinatra::Minify::Package.clean(App)
      Sinatra::Minify::Package.build(App)
    end

    should "at least create the files" do
      assert File.exist?(File.dirname(App.app_file) + '/public/js/base.min.js')
      assert File.exist?(File.dirname(App.app_file) + '/public/css/base.min.css')
    end

    should "include the css file in base.min.css" do
      control = File.read('test/fixtures/control/style-default-compressed.css')
      unknown = File.read(File.dirname(App.app_file) + '/public/css/base.min.css')

      assert unknown.include?(control)
    end

    should "include the script-1 file first in base.min.js" do
      unknown = File.read(File.dirname(App.app_file) + '/public/js/base.min.js')
      assert_equal 0, unknown.index('aoeu=234;')
    end

    should "include the script-2 file second in base.min.js" do
      unknown = File.read(File.dirname(App.app_file) + '/public/js/base.min.js')

      assert_equal 9, unknown.index('aoeu=456;')
    end
  end

  describe "second config file" do
    def setup
      app.set :minify_config, 'config/assets-glob_error.yml'
    end

    should "throw an error on an invalid glob" do
      package = Sinatra::Minify::Package.new(:js, 'base', app)
      assert_raise Sinatra::Minify::GlobNoMatchError do
        package.html
      end
    end
  end
end
