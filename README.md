Usage
-----

Add these to your `init.rb`;

    require 'sinatra/minify'
    class Main
      register Sinatra::Minify
    end

Add this to your `Rakefile`:

    load 'vendor/sinatra-minify/lib/tasks.rake'

Type `rake minify:build` to build the compressed JS/CSS files.

Also:

 * create a config/assets.yml
 * Use the helpers

(Better docs to come soon)

