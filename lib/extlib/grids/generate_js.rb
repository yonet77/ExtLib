require 'extlib/coms'

module ExtLib
	module Grids
	  module GenerateJs
      include ExtLib::Coms
	  	
	  	# Single Grid
	    def ext_grid(name, opts={})
	      grid_name = name.to_s
        config_file_text = File.open("#{RAILS_ROOT}/config/extlib/grid/#{name}.yml"){|f| f.read}
        config_file = YAML::load(ERB.new(config_file_text,nil).result(binding))

	      # Parameter Options
        opts[:grid].blank? ? grid_opts = {} : grid_opts = opts[:grid]
        opts[:store].blank? ? store_opts = {} : store_opts = opts[:store]
        opts[:colModel].blank? ? col_opts = {} : col_opts = opts[:colModel]
        opts[:grid_view].blank? ? gridview_opts = {} : gridview_opts = opts[:grid_view]
        opts[:selModel].blank? ? selmodel_opts = {} : selmodel_opts = opts[:selModel]
        opts[:plugin].blank? ? plugin_opts = {} : plugin_opts = opts[:plugin]
        
	      # DataStore
	      datastore = DataStore.new(config_file, store_opts)
	      
	      # colModel
	      colmodel = ColModel.new(config_file, col_opts)
	      
	      # GridView
	      gridview = GridView.new(config_file, gridview_opts)
	      
	      # SelectionModel
	      selectionmodel = SelectionModel.new(config_file, selmodel_opts)

        # Plugin
        plugin = Plugin.new(config_file, plugin_opts)
	      
	      # Grid
	      config_obj = {}
        config_obj = {:store=>datastore,:colModel=>colmodel,:selModel=>selectionmodel,
                      :viewConfig=>gridview,:plugins=>plugin}
	      grid = Grid.new(grid_name, config_file, config_obj, grid_opts)
	      
	      ext_code = <<-CODE
	        <%= datastore.create_js %>
	        <%= colmodel.create_js%>
	        <%= selectionmodel.create_js %>
	        <% if selectionmodel.xtype=="Ext.grid.CheckboxSelectionModel" %>
	          <%= colmodel.var %>.columns.unshift(<%= selectionmodel.var %>);
	        <% end %>
	        <%= gridview.create_js %>
	        <%= plugin.create_js %>
	        <%= grid.create_js %>
          
	        // render the grid to the specified div in the page
	        //<%= grid.var %>.render('<%= grid_name %>');
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
	    
	    # Multi Grid(For BOM Compare)
	    def ext_multi_grid(name, opts={})
	      grid_name = name.to_s
        config_file_text = File.open("#{RAILS_ROOT}/config/extlib/grid/#{name}.yml"){|f| f.read}
        config_file = YAML::load(ERB.new(config_file_text,nil).result(binding))
	      
	      # Parameter Options
	      compare_obj = {}
	      opts[:compare].each do |com|
	      	
	        opts[com][:grid].blank? ? grid_opts = {} : grid_opts = opts[com][:grid]
	        opts[com][:store].blank? ? store_opts = {} : store_opts = opts[com][:store]
	        opts[com][:colModel].blank? ? col_opts = {} : col_opts = opts[com][:colModel]
	        opts[com][:grid_view].blank? ? gridview_opts = {} : gridview_opts = opts[com][:grid_view]
	        opts[com][:selModel].blank? ? selmodel_opts = {} : selmodel_opts = opts[com][:selModel]
	        opts[com][:plugin].blank? ? plugin_opts = {} : plugin_opts = opts[com][:plugin]
	        
		      # DataStore
		      datastore = DataStore.new(config_file, store_opts, com)
		      
		      # colModel
		      colmodel = ColModel.new(config_file, col_opts, com)

		      # GridView
		      gridview = GridView.new(config_file, gridview_opts, com)
		      
		      # SelectionModel
		      selectionmodel = SelectionModel.new(config_file, selmodel_opts, com)
		      
          # Plugin
          plugin = Plugin.new(config_file, plugin_opts, com)

		      # Grid
		      config_obj = {}
          config_obj = {:store=>datastore,:colModel=>colmodel,:selModel=>selectionmodel,
                        :viewConfig=>gridview,:plugins=>plugin}
		      grid = Grid.new(grid_name, config_file, config_obj, grid_opts, com)
		      
		      compare_obj[com] = {:store=>datastore, :colmodel=>colmodel, :gridview=>gridview, :selmodel=>selectionmodel, :plugin=>plugin, :grid=>grid}
	      end
	      
	      ext_code = <<-CODE
	        <% opts[:compare].each do |id| %>
	        	<%= compare_obj[id][:store].create_js %>
	        	<%= compare_obj[id][:colmodel].create_js %>
	        	<%= compare_obj[id][:selmodel].create_js %>
	        	<% if compare_obj[id][:selmodel].xtype == "Ext.grid.CheckboxSelectionModel" %>
	         	  <%= compare_obj[id][:colmodel].var %>.columns.unshift(<%= compare_obj[id][:selmodel].var %>);
	         	<% end %>
	          <%= compare_obj[id][:gridview].create_js %>
	          <%= compare_obj[id][:plugin].create_js %>
	          <%= compare_obj[id][:grid].create_js %>
	        <% end %>
	            
	        // render the grid to the specified div in the page
	        <% opts[:compare].each do |id| %>
	          //<%= compare_obj[id][:grid].var %>.render('<%= grid_name %><%= id %>');
	        <% end %>
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

