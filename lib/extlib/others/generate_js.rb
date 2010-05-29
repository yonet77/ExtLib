require 'extlib/coms'

module ExtLib
  module Others
    module GenerateJs
      include ExtLib::Coms
      
      def ext_component(name, opts={})
        config_file_text = File.open("#{RAILS_ROOT}/config/extlib/others/#{name}.yml"){|f| f.read}
        config_file = YAML::load(ERB.new(config_file_text,nil).result(binding))
        
        config_vp = config_file[:component]
        config_vp.merge!(opts)
        var = config_vp[:var]
        xtype = config_vp[:xtype]
        config_vp = config_vp.delete_if{|key,value| [:var,:xtype].include?(key)}
        
        ext_code = <<-CODE
          var <%= var %> = new <%= xtype %>(
            <%= ext_to_json(config_vp) %>
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

