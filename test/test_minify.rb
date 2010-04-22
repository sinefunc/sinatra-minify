require 'helper'

class TestMinify < Test::Unit::TestCase
  def app
    App
  end

  def output
    last_response.body
  end

  # def builder
  #   Sinatra::Minify::Builder.new app
  # end

  should "rock pants off" do
    get '/'
    assert_match "Hello", output
  end

  should "Include all scripts" do
    get '/foo'
    assert_match /script-1.js/, output
    assert_match /script-2.js/, output
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
      File.open('tmp.html', 'w') { |f| f.write output }
      `open tmp.html`
      assert_match /base.min.js\?/, output
    end
  end

  describe "Building files" do
    def setup
      Sinatra::Minify::Builder.clean
      Sinatra::Minify::Builder.package
      # builder.clean
      # builder.build
    end

    should "Build properly" do
      assert true
    end
  end
end
