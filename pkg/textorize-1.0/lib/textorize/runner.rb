require 'osx/cocoa'

module Textorize
  class Runner
    
    def initialize(string, output, options)
      if options[:font_smoothing]
        defaults = OSX::NSUserDefaults.standardUserDefaults
        options[:original_font_smoothing] = defaults.integerForKey('AppleFontSmoothing')
        defaults.setInteger_forKey(options[:font_smoothing], 'AppleFontSmoothing')
      end
      
      app = OSX::NSApplication.sharedApplication
      app.delegate = RunnerApplication.alloc.initWithString_output_options(string, output, options)
      app.run
    end
    
  end
  
  class RunnerApplication < OSX::NSObject
    include OSX
    
    def initWithString_output_options(string, output, options)
      if init
        @string, @output, @options = string, output, options
        @window = NSWindow.alloc.objc_send(
          :initWithContentRect, [-2000, -2000, 2000, 2000],
                    :styleMask, NSBorderlessWindowMask,
                      :backing, 2,
                        :defer, 0)
        
        self
      end
    end
    
    def list_fonts
      fonts = NSFontManager.sharedFontManager.availableFontFamilies
      puts fonts.sort.join("\n")
    end
    
    def applicationDidFinishLaunching(notification)
      if @options[:util] == 'list-fonts'
        list_fonts
      else
        renderer = Renderer.new(@window, @string, @options)
        Saver.new(renderer).write_to_file(@output)
      end
      NSApplication.sharedApplication.terminate(nil)
      
      if @options[:font_smoothing]
        defaults = NSUserDefaults.standardUserDefaults
        defaults.setInteger_forKey(options[:original_font_smoothing], 'AppleFontSmoothing')
      end
    end
    
  end
  
end
