require 'digest/sha1'

SHARED_PATH = ( ENV['RACK_ENV'] == 'development' ) ? "/Users/brian/code/projects/compass2css/shared" : "/srv/www/c2c.briangonzalez.org/shared"

module Compass2CSS

    def self.compile(opts={})
      compass_project_path  = File.join( Nesta::Env.root )
      Dir.chdir SHARED_PATH

      sha = sha1 opts[:input]

      begin
        pre_compiled_output = File.open("stylesheets/#{sha}.css", "r").read
        puts 'Returning compiled file.'
        Dir.chdir compass_project_path
        return { :output => compiled_or_error(pre_compiled_output) }
      rescue Exception => e
        # File not made yet
        puts 'File not compiled yet.'
      end

      file = File.open( "scss/#{sha}.scss", 'w') do |f| 
        f.write compass_prefixes
        f.write '@import "compass";'
        f.write "\n"
        f.write( opts[:input] )
      end

      puts %x[compass compile . scss/#{sha}.scss]
      compiled_output = File.open("stylesheets/#{sha}.css", "r").read

      Dir.chdir compass_project_path

      { :output => compiled_or_error(compiled_output) }
    end

    def self.sha1(str)
      Digest::SHA1.hexdigest str
    end

    def self.compass_prefixes
      string = ""
      string << "$experimental-support-for-mozilla : true;"
      string << "$experimental-support-for-webkit : true;"
      string << "$support-for-original-webkit-gradients : true;"
      string << "$experimental-support-for-opera : false;"
      string << "$experimental-support-for-microsoft : true;"
      string << "$experimental-support-for-khtml : false;"
      return string
    end

    def self.compiled_or_error(text)
      text = text.length < 1 ? "Output is empty." : text
      text = text =~ /Syntax error/ ? "Syntax error." : text
      return text
    end

end