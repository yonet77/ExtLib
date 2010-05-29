//
// Extend the XmlTreeLoader to set some custom TreeNode attributes specific to application:
//
Ext.app.BomLoader = Ext.extend(Ext.ux.tree.XmlTreeLoader, {
    processAttributes : function(attr){
        attr.text = attr.parts_key_no + ' : ' + attr.parts_name;
        attr.attributes = {"bom_tree_id": attr.bom_tree_id, "data_type": attr.data_type, "parts_key_no": attr.parts_key_no, "parts_name": attr.parts_name, "lft": attr.lft, "rgt": attr.rgt, "product_id": attr.product_id};
        attr.iconCls = 'bom_icon';
        attr.loaded = true;
        attr.leaf = false;
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
