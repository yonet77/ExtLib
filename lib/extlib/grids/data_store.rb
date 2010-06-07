require 'extlib/coms'

module ExtLib
	module Grids
	
	  class DataStore
      include ExtLib::Coms
	  	attr_accessor :var
	  	
	  	def initialize(config_file, param_option={}, compare_id=nil)
	  		raise ArgumentError, "Missing DataStore parameter in Ext.Grid call" unless config_file[:Store]
	  		
	  		config_opts = {}
	  		config_opts = config_file[:Store]
	  		
	  		@opts = {}
	  		@opts = config_opts.merge(param_option)
        raise ArgumentError, "Missing var parameter in Store call" unless @opts[:var]
	  		@var = @opts[:var]
	  		@var = @opts[:var] + compare_id.to_s unless compare_id.blank?
        @xtype = @opts[:xtype].blank? ? @xtype = "Ext.data.XmlStore" : @xtype = @opts[:xtype]
	  		@opts = @opts.dup.delete_if{|key,val| [:var,:xtype].include?(key)}

        config_reader_opts ={}
        config_reader_opts = config_file[:Reader]
        unless config_reader_opts.blank?
          @reader_var = config_reader_opts[:var]
          @reader_xtype = config_reader_opts[:xtype]
          @reader_opts = config_reader_opts.dup.delete_if{|key,val| [:var,:xtype].include?(key)}
          @opts[:reader] = "=" + @reader_var
        end
	  	end
	  	
	  	# javascript生成
	  	def create_js()
	      ext_code = <<-CODE
           <% unless @reader_var.blank? %>
             // create the DataReader
             var <%= @reader_var %> = new <%= @reader_xtype %>(
               <%= ext_to_json(@reader_opts) %>
             );
           <% end %>

           // create the DataStore
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

