require 'extlib/coms'

module ExtLib
  module Windows
    module GenerateJs
      include ExtLib::Coms
      
      def ext_window(name, opts={})
        config_file_text = File.open("#{RAILS_ROOT}/config/extlib/window/#{name}.yml"){|f| f.read}
        config_file = YAML::load(ERB.new(config_file_text,nil).result(binding))
        
        config_win = config_file[:window]
        config_win.merge!(opts)
        var = config_win[:var]
        xtype = config_win[:xtype]
        config_win = config_win.delete_if{|key,value| [:var,:xtype].include?(key)}
        
        ext_code = <<-CODE
          var <%= var %> = new <%= xtype %>(
            <%= ext_to_json(config_win) %>
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

