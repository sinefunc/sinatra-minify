sinatra-minify
==============

Quick-start guide
-----------------

First, install the `sinatra-minify` gem.

Add these to your app's main file:

    require 'sinatra/minify'
    class Main < Sinatra::Base
      register Sinatra::Minify
    end

Add this to your app's `Rakefile`:

    load 'vendor/sinatra-minify/lib/tasks.rake'

Now add your JS/CSS packages in `config/assets.yml` (relative to your app's root path).
The files are are assumed to be in `public/js` and `public/css` by default.

    # config/assets.yml
    js:
      base:
        - jquery-1.4.2.js
        - underscore-0.6.0.js
        - app/*.js                 # Wildcards are allowed! ;)
    css:
      base:
        - common.css
        - app.*.css
      homepage:
        - home.*.css

Now add the helpers to your templates:

    # views/layout.erb (for example)
       ...
       <%= css_assets 'base' %>
       <%= css_assets 'homepage' %>
    </head>
    <body>
        ...
        <%= js_assets 'base' %>
    </body>
    </html>
    <!-- The 'base' and 'homepage' above are the names of the
         packages as defined in your config/assets.yml. -->

This will include the scripts and stylesheets as individual `<script>` and `<link>` tags.
To include the minified files instead, switch to the production environment and build
the minified files by typing `rake minify:build`.

Usage tips
==========

Building minified files
-----------------------

Minified files are built by typing:

    rake minify:build

This creates files called `<package_name>.min.js` (and `.css`) in your `public/js` and
`public/css` folders.

NOTE: Building of minified files is NOT done automatically! You must call this explicitly.
Add it to your Capistrano deploy scripts or something.

Adding sinatra-minify as a dependency (Monk)
--------------------------------------------

If your using Monk (or otherwise using the `dependency` gem), simply add the
`sinatra-minify` GitHub repo to your dependencies file.

    echo sinatra-minify git://github.com/sinefunc/sinatra-minify.git >> dependencies
    dep vendor sinatra-minify

Changing JS/CSS paths
---------------------

By default, sinatra-minify looks at `public/js` and `public/css` for your JS and CSS files,
respectively. You can change them with:

    class Main < Sinatra::Base
        register Sinatra::Minify

        set :js_path, 'public/javascripts'
        set :js_url,  '/javascripts'

        set :css_path, 'public/stylesheets'
        set :css_url,  '/stylesheets'

Forcing minification
--------------------

Minifying happens in the production environment only by default. You can force this behavior
by enabling the `force_minify` option in your app:

    class Main < Sinatra::Base
        register Sinatra::Minify

        # Always minify
        enable :force_minify

You can also define your own behavior for checking whether to minify or not.

    class Main < Sinatra::Base
        register Sinatra::Minify
        def self.minify?
          prodiction? or staging?
        end

Ignore minified files in source control
---------------------------------------

It'd be good practice to add `*.min.{css,js}` to your `.gitignore` file (or similar,
for those not using Git).

Using sinatra-minify with Less / Sass
-------------------------------------

Let's say you have some routes like

    get '/css/:file.css' do
      # some code here that opens the less file
    end

In order to properly minify this, the application must be running when
you do `rake minify:build`. By default, we assume you have your app running in
`http://localhost:4567`, but you can easily override this by doing:

    # First let's run your application. Let's say it's a rack app:
    rackup config.ru

    # Now specify the URL via:
    MINIFY_SITE_URL=http://localhost:9292 rake minify:build


Authors
=======

Sinatra-minify is co-authored by Rico Sta. Cruz and Cyril David of Sinefunc, Inc.
See more of our work on [www.sinefunc.com](http://www.sinefunc.com)!

Copyright
---------

(c) 2010 Rico Sta. Cruz, Cyril David and Sinefunc, Inc. See the LICENSE file for more details.