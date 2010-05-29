require 'extlib/coms'

module ExtLib
	module Forms
	  module GenerateJs
	  	include ExtLib::Coms

	  	# Forms
	    def ext_form(name, opts={})
	      form_name = name.to_s
        config_file_text = File.open("#{RAILS_ROOT}/config/extlib/form/#{name}.yml"){|f| f.read}
        config_file = YAML::load(ERB.new(config_file_text,nil).result(binding))

	      config_form = config_file[:form]
        config_form.merge!(opts)
        var = config_form[:var]
        xtype = config_form[:xtype]
        config_form = config_form.delete_if{|key,value| [:var,:xtype].include?(key)}

	      ext_code = <<-CODE
	        var <%= var %> = new <%= xtype %>(
            <%= ext_to_json(config_form) %>
          );
	      CODE
	      
	      js_tag = ""
	      js_tag = ::ERB.new(ext_code, nil, '>').result(binding).gsub("_n_", "\n").
	        gsub(/[ \t]{2,}/,' ').
	        gsub(/,\s+\}\);/, "\n  });").
	        gsub(/,\s+\}\)/, "  })").
	        gsub(/,\s+\}\]/, "  }]").
          gsub(/,\s+\}/, "  }").
          gsub(/,\s+\]/, "  ]").
	        gsub(/\n\s*\n/m, "\n").
	        gsub("_ss_", "  ")
	      
	      return js_tag
	    end

      # TabPanel
      def ext_tab_panel(name,opts={})
	      tab_name = name.to_s
	      config_file = YAML::load_file("#{RAILS_ROOT}/config/extlib/form/#{name}.yml")

	      config_tab = config_file[:form]
        tab_var = config_tab[:var]
        tab_xtype = config_tab[:xtype]
        config_tab = config_tab.dup.delete_if{|key,value| [:var,:xtype].include?(key)}

	      ext_code = <<-CODE
	        var <%= tab_var %> = new <%= tab_xtype] %>({
            <%= ext_to_json(config_tab) %>
					});
					<%= tab_var %>.render('<%= tab_name %>');
	      CODE

	      js_tag = ""
	      js_tag = ::ERB.new(ext_code, nil, '>').result(binding).gsub("_n_", "\n").
	        gsub(/[ \t]{2,}/,' ').
	        gsub(/,\s+\}\);/, "\n  });").
          gsub(/,\s+\}\)/, "\n  })").
	        gsub(/\n\s*\n/m, "\n").
	        gsub("_ss_", "  ")

	      return js_tag
      end
	  end
  end
end

