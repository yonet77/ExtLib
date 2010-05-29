module ExtjsHelper

  def ext_js_function
    javascript_tag(%Q!
      function reloadGrid(grid_id, paramUrl){
        var grid = Ext.getCmp(grid_id);
        grid.getStore().proxy.setUrl(paramUrl);
        if (grid.getBottomToolbar()==null){
          grid.getStore().reload();
        } else {
          var pagesize = Ext.getCmp(grid_id).getBottomToolbar().pageSize;
          grid.getStore().reload({params:{start:0, limit:pagesize}});
        }
      }

      function reloadTree(tree_id, params){
        var tree = Ext.getCmp(tree_id);
        var topNode = tree.getRootNode();
        if(params \!= null){
          if(params == 'bomtree'){
            tree.getLoader().baseParams = {data_type: topNode.attributes.data_type, bom_tree_id: topNode.attributes.bom_tree_id};
          }
        }
        tree.getLoader().load(topNode);
        tree.getRootNode().expand();
      }

      function getSelectedRow(grid_id){
        return Ext.getCmp(grid_id).selModel.getSelections();
      }

    !)
  end

  def main_form_viewport_adjust_layout
    (%Q!
      function adjustLayout(){
        //ImportBOM
        Ext.getCmp("id_importbom_inputform").add(var_bom_import_form);
        //Ext.getCmp("id_importbom_imported_bom_grid").add(var_imported_bom_grid);

        //ProductBOM
        Ext.getCmp("id_productbom_product_list").add(var_product_tree_list);
        Ext.getCmp("id_productbom_bom_list").add(var_bom_info_grid);
        Ext.getCmp("id_productbom_bom_info_sum").add(var_bom_info_summary_grid);
        Ext.getCmp("id_productbom_bom_info_all_sum").add(var_bom_info_all_summary_grid);

        //PartsDatabase
        Ext.getCmp("id_partsdatabase_mst_parts_list").add(var_mst_parts_tree);
        Ext.getCmp("id_partsdatabase_parts_list").add(var_parts_list_grid);

        //Coompre
        Ext.getCmp("id_comparebom_bom_compare_list").add(var_compare_product_tree_list);

        //ExportBOM
        //Ext.getCmp("id_export_product_tree").add(var_product_tree_list);

        // Set Active Tab
        //Ext.getCmp("main_form_tabpanel").setActiveTab(0);
      }

      adjustLayout();
    !)
  end
  
  def js_bom_info

    javascript_tag(%Q!

      function upload_bom_info(form_id, value, fb){
        if(value \!= ''){
          Ext.getCmp(form_id).getForm().submit({
            url: \"#{url_for(:conrtoller=>:fuji, :action=>:import_bom, :authenticity_token=>form_authenticity_token)}\",
            params: {filename: value},
            waitMsg: \"#{t('bom.data_uploading_msg')}\",
            success: function(fp, o){Ext.Msg.alert('message',\"#{t('bom.data_upload_complete_msg')}\"); fb.reset();},
            failure: function(fp, o){Ext.Msg.alert('alert',o.result.errors.msg);}
          });
        }
      }

      function open_summary_graph(){
				win_bom_summary_graph = window.open("#{url_for(:controller=>:fuji, :action=>:bom_info_summary_graph)}","bom_info_summary_graph","width=850,height=600,status=no,menubar=no,scrollbars=yes");
      }

      function open_st_image(){
				win_bom_st_image = window.open("#{url_for(:controller=>:fuji, :action=>:bom_info_structure_image)}","bom_st_image","width=850,height=600,status=no,menubar=no,scrollbars=yes");
      }

      function download_csv(){
				location.href='#{url_for(:controller=>:fuji, :action=>:export_bom)}';
      }

      function download_qty_by_date(){
        location.href='#{url_for(:controller=>:fuji, :action=>:export_qty_by_date)}';
      }

      function relate_trn_to_mst(node, trn_product_id, mst_product_id){
        var loadMask = new Ext.LoadMask(node.getOwnerTree().getEl(), {msg:"Create Relation..."});
        loadMask.show();
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:relate_trnproduct_to_mstproduct)}',
          params: {trn_pd_id: trn_product_id, mst_pd_id: mst_product_id},
          success: function(){loadMask.hide();},
          failure: function(){loadMask.hide();}
        });
      }

      function edit_product(node, product_data_type, product_id, command, maskMsg){
        var loadMask = new Ext.LoadMask(node.getOwnerTree().getEl(), {msg: maskMsg});
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:edit_product)}',
          params: {pd_id: product_id, pd_data_type: product_data_type, command: command},
          success: function(){loadMask.hide();},
          failure: function(){loadMask.hide();}
        });
      }

      function init_product_edit_window(){
        Ext.getCmp("id_product_edit_form").getForm().reset();
        Ext.getCmp("id_product_edit_window").hide();
      }

      function reload_bom(product_data_type, product_id, bom_tree_id){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:reload_bom_info)}',
          params: {pd_id: product_id, bom_tree_id: bom_tree_id, pd_data_type: product_data_type}
        });
      }

      function edit_bom_data(grid_id){
        var store = Ext.getCmp(grid_id).getStore();
        var recs = store.getModifiedRecords();
        var loadMask = new Ext.LoadMask(Ext.getCmp(grid_id).getEl(), {msg:"Editing..."});
        var update_data = [];
        for(var i=0; i<recs.length; i++){
          var wk = recs[i].getChanges();
          wk["bom_id"] = recs[i]["data"]["bom_id"];
          update_data[i] = wk;
        }
        loadMask.show();
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:save_bom_info)}',
          params: {data: Ext.util.JSON.encode(update_data)},
          success: function(){store.commitChanges(); loadMask.hide();},
          failure: function(){store.rejectChanges(); loadMask.hide();}
        });
      }

      function edit_bom_structure(grid_id, com){
        var selRow = getSelectedRow(grid_id);
        if (selRow.length == 0){Ext.Msg.alert('alert','#{t('bom.bom_info_grid_title') + t('msg.alert_no_row_selected')}'); return}
        var bom_ids = [];
        for(var i=0; i<selRow.length; i++){
          bom_ids.push(selRow[i]["data"]["bom_id"]);
        }
        var bom_id = selRow[0]["data"]["bom_id"];
        var loadMask = new Ext.LoadMask(Ext.getCmp(grid_id).getEl(), {msg:"Editing..."});
        loadMask.show();
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:edit_bom_structure)}',
          params: {bom_id: bom_id, bom_ids: bom_ids.join(','), command: com},
          success: function(){loadMask.hide();},
          failure: function(){loadMask.hide();}
        });
      }

      function calculate_delivery_date(grid_id){
        var loadMask = new Ext.LoadMask(Ext.getCmp(grid_id).getEl(), {msg:"Editing..."});
        loadMask.show();
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:calculate_delivery_date)}',
          success: function(){loadMask.hide();},
          failure: function(){loadMask.hide();}
        });
      }

    !)
  end


  def js_parts_search
    javascript_tag(%Q!
      function search_parts(form_id){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji,:action=>:reload_parts_list)}',
          form: form_id
        });
      }

      function search_parts_by_key(parts_key){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji,:action=>:reload_parts_list)}',
          params: {parts_key_no: parts_key}
        });
      }

      function set_to_master(bom_data_id, data_type){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:set_to_master)}',
          params: {bom_data_id: bom_data_id, data_type: data_type}
        });
      }
    !)
  end

  def js_bom_compare(grids_dom_id)

    javascript_tag(%Q!
      function open_compare_image(){
				win_bom_compare_image = window.open("#{url_for(:controller=>:fuji, :action=>:bom_info_structure_image)}","bom_compare_image","width=850,height=600,status=no,menubar=no,scrollbars=yes");
      }

      function search_compare_product(search_dom_id){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji,:action=>:reload_compare_product_list)}',
          form: search_dom_id
        });
      }

      function reload_bom_compare(tree_id){
        // get selected Row data from TreeList
        var selNodes = Ext.getCmp(tree_id).getSelectionModel().getSelectedNodes();
        if (selNodes.length == 0){Ext.Msg.alert('alert','#{t('bom.product_grid_title') + t('msg.alert_no_row_selected')}'); return}
        var pd_list = [];
        for(var i=0; i<selNodes.length;i++){
          pd_list.push(selNodes[i].attributes.data_type + '_' + selNodes[i].attributes.pd_id);
        }
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:fuji, :action=>:reload_bom_compare)}',
          params: {pd_ids: pd_list.join(','), grid_dom_id: '#{grids_dom_id}'}
        });
      }
    !)
  end


  def js_data_item_tag
    javascript_tag(%Q!
      function save_data_item(form_id){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:nasubi,:action=>:save_data_item, :authenticity_token=>form_authenticity_token)}',
          form: form_id,
          success: function(){Ext.Msg.alert('message', \"#{t('com.save_complete')}\");}
        });
      }
    !)
  end

  def js_user_admin_tag
    javascript_tag(%Q!
      function add_user_group(){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:nasubi,:action=>:add_user_group)}'
        });
      }

      function del_user_group(grid_id){
        // get selected Row data from user_group_grid
        var selRow = getSelectedRow(grid_id);
        if (selRow.length == 0){Ext.Msg.alert('alert','#{t('admin.user_group_grid_title') + t('msg.alert_no_row_selected')}'); return}
        var user_gr_id = selRow[0]["data"]["group_id"];
        Ext.MessageBox.confirm('Confirm', '#{t('msg.confirm_delete')}', function(btn, text){
          if (btn == 'yes'){
            Ext.Ajax.request({
              url: '#{url_for(:controller=>:nasubi, :action=>:del_user_group)}',
              params: {user_group_id: user_gr_id}
            });
          }
        });
      }

      function save_user_info(form_id){
        Ext.Ajax.request({
          url: '#{url_for(:controller=>:nasubi,:action=>:save_user, :authenticity_token=>form_authenticity_token)}',
          success: function(){Ext.Msg.alert('message', \"#{t('com.save_complete')}\");},
          form: form_id
        });
      }

      function del_user(grid_id){
        // get selected Row data from user_group_grid
        var selRow = getSelectedRow(grid_id);
        if (selRow.length == 0){Ext.Msg.alert('alert','#{t('admin.user_grid_title') + t('msg.alert_no_row_selected')}'); return}
        var userid = selRow[0]["data"]["user_id"];
        Ext.MessageBox.confirm('Confirm', '#{t('msg.confirm_delete')}', function(btn, text){
          if (btn == 'yes'){
            Ext.Ajax.request({
              url: '#{url_for(:controller=>:nasubi, :action=>:del_user)}',
              params: {user_id: userid}
            });
          }
        });
      }

      function get_user_info(form_id){
        Ext.getCmp(form_id).getForm().load({
          url: '#{url_for(:controller=>:nasubi, :action=>:get_user_info)}',
          waitMsg:'Loading'
        });
      }

      function load_user_info(grid_id, win_id, form_id){
        var selRow = getSelectedRow(grid_id);
        if (selRow.length == 0){Ext.Msg.alert('alert','#{t('admin.user_grid_title') + t('msg.alert_no_row_selected')}'); return}
        Ext.getCmp(form_id).getForm().reset();
        Ext.getCmp(form_id).getForm().loadRecord(selRow[0]);
        show_window(win_id, form_id, false);
      }

      function show_window(win_id, form_id, add){
        var win = Ext.getCmp(win_id);
        if (add){Ext.getCmp(form_id).getForm().reset();}
        if (win.isVisible()==false){win.show();}
      }
    !)
  end

  def js_account_tag
    javascript_tag(%Q!
      function edit_account(form_id, com){
        var com_url;
        switch(com){
          case 'update':
            com_url = '#{url_for(:controller=>:nasubi,:action=>:save_account,:authenticity_token=>form_authenticity_token)}';
            break;
          case 'delete':
            com_url = '#{url_for(:controller=>:nasubi,:action=>:destroy_account,:authenticity_token=>form_authenticity_token)}';
            break;
          default:
            com_url = '#{url_for(:controller=>:nasubi,:action=>:account_admin,:authenticity_token=>form_authenticity_token)}';
            break;
        }
        Ext.Ajax.request({
          url: com_url,
          form: form_id
        });
      }
    !)
  end

end
