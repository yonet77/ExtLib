require 'extlib/coms'

module ExtLib
	module Grids
	  class SelectionModel
      include ExtLib::Coms
	  	attr_accessor :var, :xtype
	  	
	  	def initialize(config_file, param_option={}, compare_id=nil)
	  		puts '-------------------------'
	  		puts 'SelectionModel..'
	  		puts '-------------------------'
	  		
	  		config_opts = {}
	  		config_opts = config_file[:SelectionModel]
	  		
	  		@opts = {}
	  		unless config_opts.blank?
	  			@opts = config_opts.merge(param_option)
          raise ArgumentError, "Missing var parameter in SelectionModel call" unless @opts[:var]
	  			@var = @opts[:var]
	  			@var = @opts[:var] + compare_id.to_s unless compare_id.blank?
          raise ArgumentError, "Missing xtype parameter in SelectionModel call" unless @opts[:xtype]
	  			@xtype = @opts[:xtype]
	  			@opts = @opts.dup.delete_if{|key,val| [:var,:xtype].include?(key)}
	  		end
	  		
	  	end
	  	
	  	# javascript生成
	  	def create_js()
	  		return "" if @opts.blank?
	  		
	      ext_code = <<-CODE
           // create the SelectionModel
           var <%= @var %> = new <%= @xtype %>(
             <%= ext_to_json(@opts) %>
           );
	      CODE
	      
	      js_tag = ""
	      js_tag = ::ERB.new(ext_code, nil, '>').result(binding).gsub("_n_", "\n").
	        gsub(/[ \t]{2,}/,' ').
	        gsub(/,\s+\}\);/, " });").
          gsub(/,\s+\}\)/, " })").
	        gsub(/\n\s*\n/m, "\n").
	        gsub("_ss_", "  ")
	      
	      
	      return js_tag
	  	end
	    
	  end
  end
end

