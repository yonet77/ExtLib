Ext.namespace('Ext.ux.dd');

Ext.ux.dd.GridDragDropRowOrder = Ext.extend(Ext.util.Observable,{
    copy: false,
    scrollable: false,
    constructor : function(config){
        if (config)
            Ext.apply(this, config);
        this.addEvents({
            /**
             * @event beforerowmove
             * Fires before the row is moved. If the handler returns false, the event is cancelled.
             * @param {GridReorderDropTarget} this
             * @param {int} oldIndex
             * @param {int} newIndex
             * @param {Object} records
            */ 
            beforerowmove: true,
            /**
             * @event afterrowmove
             * Fires after the row is moved.
             * @param {GridReorderDropTarget} this
             * @param {int} oldIndex
             * @param {int} newIndex
             * @param {Object} records
            */ 
            afterrowmove: true,
            /**
             * @event beforerowcopy
             * Fires before the row is copied. If the handler returns false, the event is cancelled.
             * @param {GridReorderDropTarget} this
             * @param {int} oldIndex
             * @param {int} newIndex
             * @param {Object} records
            */ 
            beforerowcopy: true,
            /**
             * @event afterrowcopy
             * Fires after the row is copied.
             * @param {GridReorderDropTarget} this
             * @param {int} oldIndex
             * @param {int} newIndex
             * @param {Object} records
            */ 
            afterrowcopy: true
        });
        Ext.ux.dd.GridDragDropRowOrder.superclass.constructor.call(this);
    },
    init : function (grid){
        this.grid = grid;
        grid.enableDragDrop = true;
        grid.on({
            render: { fn: this.onGridRender, scope: this, single: true }
        });
    },
    onGridRender : function (grid){
        var self = this;
        this.target = new Ext.dd.DropTarget(grid.getEl(),{
            ddGroup: grid.ddGroup || 'GridDD',
            grid: grid,
            gridDropTarget: this,
            notifyDrop: function(dd, e, data){
                // Remove drag lines. The 'if' condition prevents null error when drop occurs without dragging out of the selection area
                if (this.currentRowEl){
                    this.currentRowEl.removeClass('grid-row-insert-below');
                    this.currentRowEl.removeClass('grid-row-insert-above');
                }
                // determine the row
                var t = Ext.lib.Event.getTarget(e);
                var rindex = this.grid.getView().findRowIndex(t);
                if (rindex === false || rindex == data.rowIndex){
                    return false;
                }
                // fire the before move/copy event
                if (this.gridDropTarget.fireEvent(self.copy ? 'beforerowcopy' : 'beforerowmove', this.gridDropTarget, data.rowIndex, rindex, data.selections, this.insertposition, 123) === false){
                    return false;
                }
                // update the store
                var ds = this.grid.getStore();
                // Changes for multiselction by Spirit
                var selections = new Array();
                var keys = ds.data.keys;
                for (var key in keys){
                    for (var i = 0; i < data.selections.length; i++){
                        if (keys[key] == data.selections[i].id){
                            // Exit to prevent drop of selected records on itself.
                            if (rindex == key){
                                return false;
                            }
                            selections.push(data.selections[i]);
                        }
                    }
                }
                // fix rowindex based on before/after move
                if (rindex > data.rowIndex && this.rowPosition < 0){
                    rindex--;
                }
                if (rindex < data.rowIndex && this.rowPosition > 0){
                    rindex++;
                }
                // fix rowindex for multiselection
                if (rindex > data.rowIndex && data.selections.length > 1){
                    rindex = rindex - (data.selections.length - 1);
                }
                // we tried to move this node before the next sibling, we stay in place
                if (rindex == data.rowIndex){
                    return false;
                }
                // fire the before move/copy event
                /* dupe - does it belong here or above???
                if (this.gridDropTarget.fireEvent(self.copy ? 'beforerowcopy' : 'beforerowmove', this.gridDropTarget, data.rowIndex, rindex, data.selections, 123) === false){
                    return false;
                }
                */
                // fire the after move/copy event
                this.gridDropTarget.fireEvent(self.copy ? 'afterrowcopy' : 'afterrowmove', this.gridDropTarget, data.rowIndex, rindex, data.selections, this.insertposition);                return true;
            },
            notifyOver: function(dd, e, data){
                var t = Ext.lib.Event.getTarget(e);
                var rindex = this.grid.getView().findRowIndex(t);
                // Similar to the code in notifyDrop. Filters for selected rows and quits function if any one row matches the current selected row.
                var ds = this.grid.getStore();
                var keys = ds.data.keys;
                for (var key in keys){
                    for (var i = 0; i < data.selections.length; i++){
                        if (keys[key] == data.selections[i].id){
                            if (rindex == key){
                                if (this.currentRowEl){
                                    this.currentRowEl.removeClass('grid-row-insert-below');
                                    this.currentRowEl.removeClass('grid-row-insert-above');
                                    this.insertposition = null;
                                    this.grid.getView().dragZone.getProxy().update("<p>(No Drop..)</p>");
                                }
                                return this.dropNotAllowed;
                            }
                        }
                    }
                }
                // If on first row, remove upper line. Prevents negative index error as a result of rindex going negative.
                if (rindex < 0 || rindex === false){
                    this.currentRowEl.removeClass('grid-row-insert-above');
                    this.insertposition = null;
                    this.grid.getView().dragZone.getProxy().update("<p>(No Drop..)</p>");
                    return this.dropNotAllowed;
                }
                try{
                    var currentRow = this.grid.getView().getRow(rindex);
                    // Find position of row relative to page (adjusting for grid scroll position)
                    var resolvedRow = new Ext.Element(currentRow).getY() - this.grid.getView().scroller.dom.scrollTop;
                    var rowHeight = currentRow.offsetHeight;
                    // Cursor relative to a row. -ve value implies cursor is above the row middle and +ve value implues cursor is below the row middle.
                    this.rowPosition = e.getPageY() - resolvedRow;
                    // Clear drag line.
                    if (this.currentRowEl){
                        this.currentRowEl.removeClass('grid-row-insert-below');
                        this.currentRowEl.removeClass('grid-row-insert-above');
                        this.insertposition = null;
                        this.grid.getView().dragZone.getProxy().update("<p>(No Drop..)</p>");
                    }
                    if (this.rowPosition > (2*rowHeight/3)){
                        // If the pointer is on the bottom half of the row.
                        this.currentRowEl = new Ext.Element(currentRow);
                        this.currentRowEl.addClass('grid-row-insert-below');
                        this.insertposition = "bottom";
                        //this.grid.getView().dragZone.getProxy().setStatus("x-dd-drop-ok");
                        this.grid.getView().dragZone.getProxy().update("<p>(insert below)</p>");
                    } else if (this.rowPosition < (rowHeight/3)) {
                        // If the pointer is on the top half of the row.
                        if (rindex - 1 >= 0){
                            var previousRow = this.grid.getView().getRow(rindex - 1);
                            this.currentRowEl = new Ext.Element(previousRow);
                            this.currentRowEl.addClass('grid-row-insert-below');
                            this.insertposition = "top";
                            //this.grid.getView().dragZone.getProxy().setStatus("x-dd-drop-ok");
                            this.grid.getView().dragZone.getProxy().update("<p>(insert above)</p>");
                        } else {
                            // If the pointer is on the top half of the first row.
                            this.currentRowEl.addClass('grid-row-insert-above');
                            this.insertposition = "top";
                            //this.grid.getView().dragZone.getProxy().setStatus("x-dd-drop-ok");
                            this.grid.getView().dragZone.getProxy().update("<p>(insert above)</p>");
                        }
                    } else {
                        this.insertposition = "middle";
                        //this.grid.getView().dragZone.getProxy().setStatus("x-dd-drop-ok");
                        this.grid.getView().dragZone.getProxy().update("<p>(replace)</p>");
                    }
                } catch (err){
                    //console.warn(err);
                    alert(err);
                    rindex = false;
                }
                return (rindex === false)? this.dropNotAllowed : this.dropAllowed;
            },
            notifyOut: function(dd, e, data){
                // Remove drag lines when pointer leaves the gridView.
                if (this.currentRowEl){
                    this.currentRowEl.removeClass('grid-row-insert-above');
                    this.currentRowEl.removeClass('grid-row-insert-below');
                }
                this.insertposition = null;
                this.grid.getView().dragZone.getProxy().update("<p>(No Drop..)</p>");
            }
        });
        if (this.targetCfg){
            Ext.apply(this.target, this.targetCfg);
        }
        if (this.scrollable){
            Ext.dd.ScrollManager.register(grid.getView().getEditorParent());
            grid.on({
                beforedestroy: this.onBeforeDestroy,
                scope: this,
                single: true
            });
        }
    },
    getTarget: function(){ return this.target;},
    getGrid: function(){ return this.grid;},
    getCopy: function(){ return this.copy ? true : false;},
    setCopy: function(b){ this.copy = b ? true : false;},
    onBeforeDestroy : function (grid){
        // if we previously registered with the scroll manager, unregister
        // it (if we do not it will lead to problems in IE)
        Ext.dd.ScrollManager.unregister(grid.getView().getEditorParent());
    }
});
