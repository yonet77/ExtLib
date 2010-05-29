require 'extlib/coms'

module ExtLib
  module Buttons
    module GenerateJs
      include ExtLib::Coms
      
      def ext_button(name, opts={})

        ext_code = <<-CODE
          var <%= name %> = new Ext.Button(
            <%= ext_to_json(opts) %>
          );
        CODE
        
	      js_tag = ""
	      js_tag = ::ERB.new(ext_code, nil, '>').result(binding).gsub("_n_", "\n").
	        gsub(/[ \t]{2,}/,' ').
	        gsub(/,\s+\}\);/, "\n });").
          gsub(/,\s+\}\)/, " })").
	        gsub(/\n\s*\n/m, "\n").
	        gsub("_ss_", "  ")
	      
	      return js_tag
      end
    end
  end
end

