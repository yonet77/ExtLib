require 'extlib/coms'

module ExtLib
  module Grids
    class Plugin
      include ExtLib::Coms
	  	attr_accessor :var, :xtype

      def initialize(config_file, param_option={}, compare_id=nil)
	  		puts '-------------------------'
	  		puts 'Plugin..'
	  		puts '-------------------------'
	  		config_opts = {}
	  		config_opts = config_file[:plugin]
        return nil if config_opts.blank?
        @var = []
        @opts = []
        config_opts.each do |c|
          raise ArgumentError, "Missing var parameter in Plugin call" unless c[:var]
          raise ArgumentError, "Missing xtype parameter in Plugin call" unless c[:xtype]
          wk = {}
	  			wk = c
          wk.merge!(param_option[c[:xtype]]) unless param_option[c[:xtype]].blank?
	  			wk[:var] += compare_id.to_s unless compare_id.blank?
          @opts << wk
          @var << wk[:var]
        end
        @var = "[#{@var.join(",")}]"
      end

      # javascript生成
      def create_js
        return "" if @opts.blank?
        _tag = ""
        @opts.each do |op|
          case op[:xtype]
          when "Ext.ux.grid.RowEditor"
            _tag += row_editor(op)
          when "Ext.ux.dd.GridDragDropRowOrder"
            _tag += dragdrop_roworder(op)
          end
        end
        return _tag
      end

	  	def row_editor(opts)
        config = opts.dup.delete_if{|key,val| [:var,:xtype,:success,:failure,:saveurl].include?(key)}
	      ext_code = <<-CODE
           // create the Edit Plugin
	         var <%= opts[:var] %> = new <%= opts[:xtype] %>(
             <%= ext_to_json(config) %>
	         );
	         <%= opts[:var] %>.on({
	           scope: this,
	           afteredit: function(roweditor, changes, record, rowIndex){
	             Ext.Ajax.request({
	               url: '<%= opts[:saveurl] %>',
	               method: 'POST',
	               params: record.data,
                 <% unless opts[:success].blank? %>
                   success: function() {<%= opts[:success] %>},
                 <% end %>
                 <% unless opts[:failure].blank? %>
	                 failure: function() {<%= opts[:failure] %>}
                 <% end %>
	             });
	           }
	         });
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

      def dragdrop_roworder(opts)
        config = opts.dup.delete_if{|key,val| [:var,:xtype].include?(key)}
	      ext_code = <<-CODE
           // create the Drag&Drop Plugin
	         var <%= opts[:var] %> = new <%= opts[:xtype] %>(
             <%= ext_to_json(config) %>
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
