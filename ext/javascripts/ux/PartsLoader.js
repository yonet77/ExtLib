//
// Extend the XmlTreeLoader to set some custom TreeNode attributes specific to application:
//
Ext.app.PartsLoader = Ext.extend(Ext.ux.tree.XmlTreeLoader, {
    processAttributes : function(attr){
        attr.text = attr.parts_key_no + ' : ' + attr.parts_name;
        attr.attributes = {"id": attr.id, "data_type": attr.data_type, "parts_key_no": attr.parts_key_no, "parts_name": attr.parts_name};
        if(attr.data_type == 'mst'){ // Master
            attr.iconCls = 'folder';
            attr.loaded = true;
            attr.leaf = false;
            //attr.expanded = true;
        }
    }
});
