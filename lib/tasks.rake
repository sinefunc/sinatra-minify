namespace :minify do
  desc "Builds the minified CSS and JS assets."
  task :build do
    require 'init'
    puts "Building..."

    files = Sinatra::Minify::Package.build
    files.each { |f| puts " * #{File.basename f}" }
    puts "Construction complete!"
  end
end
