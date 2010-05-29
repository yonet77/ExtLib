require 'extlib/coms'

module ExtLib
	module Grids
	  class ColModel
      include ExtLib::Coms
	  	attr_accessor :var
	  	
	  	def initialize(config_file, param_option={}, compare_id=nil)
	  		puts '-------------------------'
	  		puts 'ColModel..'
	  		puts '-------------------------'
	  		raise ArgumentError, "Missing colModel parameter in Ext.Grid call" unless config_file[:colModel]
	  		
	  		config_opts = {}
	  		config_opts = config_file[:colModel]
	  		
	  		@opts = {}
	  		@opts = config_opts.merge(param_option)
        raise ArgumentError, "Missing var parameter in ColModel call" unless @opts[:var]
	  		@var = @opts[:var]
	  		@var = @opts[:var] + compare_id.to_s unless compare_id.blank?
	  		@opts = @opts.dup.delete_if{|key,val| [:var,:xtype].include?(key)}
        @cols = @opts.dup.delete_if{|key,val| [:defaults, :columns].include?(key)}
	  	end
	  	
	  	# javascript生成
	  	def create_js()
	      
	      ext_code = <<-CODE
	        // create the ColModel
	        var <%= @var%> = new Ext.grid.ColumnModel({
	          <% unless @opts[:defaults].blank? %>
	            defaults: <%= ext_to_json(@opts[:defaults]) %>,
	          <% end %>
	          columns: <%= ext_to_json(@opts[:columns]) %>
            <% unless @cols.blank? %>
            , <%= ext_to_json(@cols) %>
            <% end %>
	        });
	      CODE
	      
	      js_tag = ""
	      js_tag = ::ERB.new(ext_code, nil, '>').result(binding).gsub("_n_", "\n").
	        gsub(/[ \t]{2,}/,' ').
	        gsub(/,\s+\}\);/, "\n  });").
	        gsub(/,\s+\}\)/, " })").
	        gsub(/,\s+\}\]/, " }]").
          gsub(/,\s+\}/, " }").
          gsub(/,\s+\]/, " ]").
	        gsub(/\n\s*\n/m, "\n").
	        gsub("_ss_", "  ")
	      
	      
	      return js_tag
	  	end
	    
	  end
  end
end

