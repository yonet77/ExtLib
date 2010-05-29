//
// Extend the XmlTreeLoader to set some custom TreeNode attributes specific to application:
//
Ext.app.ProductLoader = Ext.extend(Ext.ux.tree.XmlTreeLoader, {
    processAttributes : function(attr){
        attr.text = attr.pd_key_no + ' : ' + attr.pd_name;
        attr.attributes = {"pd_id": attr.pd_id, "data_type": attr.data_type, "pd_key_no": attr.pd_key_no, "pd_name": attr.pd_name, "bom_cnt": attr.bom_cnt, "top_tree_id": attr.top_tree_id};
        if(attr.data_type == 'mst'){ // Master Product
            attr.iconCls = 'mst_product';
            attr.loaded = true;
            attr.leaf = false;
            attr.expanded = true;
            attr.draggable = false;
        }
        else if(attr.data_type == 'trn'){ // Transaction Product
            attr.iconCls = 'trn_product';
            attr.leaf = true;
            attr.draggable = true;
        }
    },
    
    listeners : {
        beforeload: function(loader, node, callback){
            var loadMask = new Ext.LoadMask(node.getOwnerTree().getEl(), {msg:"Loading..."});
            loadMask.show();
            node.attributes["mask"] = loadMask;
        },
        load: function(loader, node, response){
            var loadMask = node.attributes["mask"];
            loadMask.hide();
        }
    }
});
