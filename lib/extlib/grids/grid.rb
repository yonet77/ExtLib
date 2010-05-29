require 'extlib/coms'

module ExtLib
	module Grids
    
	  class Grid
      include ExtLib::Coms
	  	attr_accessor :var, :id
	  	
	  	def initialize(grid_name, config_file, config_obj, param_option={}, compare_id=nil)
	  		puts '-------------------------'
	  		puts 'Grid..'
	  		puts '-------------------------'
	  		raise ArgumentError, "Missing Grid parameter in Ext.Grid call" unless config_file[:grid]
	  		
	  		config_opts = {}
	  		config_opts = config_file[:grid]
	  		
	  		@opts = {}
	  		@opts = config_opts.merge(param_option)
        raise ArgumentError, "Missing var parameter in Gird call" unless @opts[:var]
        raise ArgumentError, "Missing xtype parameter in Gird call" unless @opts[:xtype]
	  		@var = @opts[:var]
	  		@var = @opts[:var] + compare_id.to_s unless compare_id.blank?
        @renderTo = @opts[:renderTo]
        @renderTo = @renderTo + compare_id.to_s unless compare_id.blank?
	  		@id = @opts[:id]        
        @xtype = @opts[:xtype]
        @tbar = @opts[:tbar]
        @bbar = @opts[:bbar]
	  		@opts = @opts.dup.delete_if{|key,val| [:id,:var,:xtype,:bbar,:tbar,:renderTo].include?(key)}
        @config_obj = config_obj.dup.delete_if{|key, val| val.var.blank?}

	  	end
	  	
	  	# javascript生成
	  	def create_js()
	      ext_code = <<-CODE
           // create the Grid
           var <%= @var %> = new <%= @xtype %>({
             id: "<%= @id %>",
             <% unless @renderTo.blank? %>
               renderTo: "<%= @renderTo %>",
             <% end %>
             <% @config_obj.each do |key, val| %>
               <%= key %>: <%= val.var %>,
             <% end %>
             <%= ext_to_json(@opts)[1..-2] %>,
             <% unless @tbar.blank? %>
               tbar: <%= ext_to_json(@tbar)%>,
             <% end %>
             <% unless @bbar.blank? %>
               bbar: new Ext.PagingToolbar({
               <%= ext_to_json(@bbar)[1..-2] %>,
               store: <%= @config_obj[:store].var %>,
               displayInfo: true
               }),
             <% end %>
           });
	      CODE
	      
	      js_tag = ""
	      js_tag = ::ERB.new(ext_code, nil, '>').result(binding).gsub("_n_", "\n").
	        gsub(/[ \t]{2,}/,' ').
	        gsub(/,\s+\}\);/, "\n  });").
          gsub(/,\s+\}\)/, " })").
          gsub(/,\s+\]/, " ]").
          gsub(/,\s+\}/, " }").
	        gsub(/\n\s*\n/m, "\n").
	        gsub("_ss_", "  ")
	      
	      return js_tag
	  	end
	    
	  end
  end
end

