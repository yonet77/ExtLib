
module ExtLib
  def include_ext_js
      <<-JS
      <!--<script>
      if(window.Event) {
          Object.extend(Event,{
              element: function(event) {
                var node = Event.extend(event).target;
                return node && Element.extend(node.nodeType == Node.TEXT_NODE ? node.parentNode : node);
              },

              pointer: function(event) {
                return {
                  x: event.pageX || (event.clientX +
                    ((document && document.documentElement && document.documentElement.scrollLeft)
                        || (document && document.body && document.body.scrollLeft))),
                  y: event.pageY || (event.clientY +
                    ((document && document.documentElement && document.documentElement.scrollTop)
                        || (document && document.body && document.body.scrollTop)))
                };
              }
          });
      }
      </script>-->
      <!--<script src="/javascripts/ext/adapter/ext/ext-base.js" type="text/javascript"></script>-->
      <script src="/javascripts/ext/adapter/prototype/ext-prototype-adapter.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ext-all.js" type="text/javascript"></script>
      
      <!-- Debug -->
      <!--<script src="/javascripts/ext/ext-all-debug.js" type="text/javascript"></script>-->
      <!-- Locale -->
      <!--<script src="/javascripts/ext/locale/ext-lang-ja.js" type="text/javascript"></script>-->
      
      <script src="/javascripts/ext/ux/RowEditor.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/BufferView.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/FileUploadField.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/GridDragDropRowOrder.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/XmlTreeLoader.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/ProductLoader.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/PartsLoader.js" type="text/javascript"></script>
      <script src="/javascripts/ext/ux/BomLoader.js" type="text/javascript"></script>
      <!--<script src="/javascripts/ext/ux/LockingGridView.js" type="text/javascript"></script>-->
      JS
  end
    
  def include_ext_css
      <<-CSS
      <link href="/stylesheets/ext/css/ext-all.css" media="screen" rel="stylesheet" type="text/css" />
      <link href="/stylesheets/ext/css/ux/RowEditor.css" media="screen" rel="stylesheet" type="text/css" />
      <link href="/stylesheets/ext/css/ux/LockingGridView.css" media="screen" rel="stylesheet" type="text/css" />
      <link href="/stylesheets/ext/css/ux/FileUploadField.css" media="screen" rel="stylesheet" type="text/css" />
      <link href="/stylesheets/ext/css/ux/XmlTreeLoader.css" media="screen" rel="stylesheet" type="text/css" />
      CSS
  end

  def ext_on_ready_tag(&block)
    raise ArgumentError, "Missing Block in ext_on_ready call" unless block_given?

    content = capture(&block)

    concat("<script type=\"text/javascript\">\n")
    concat("Ext.onReady(function(){\n")
    concat(content)
    concat("\n});\n")
    concat("</script>".html_safe!)
  end

end


# Grid
require 'extlib/grids/generate_js'
require 'extlib/grids/data_store'
require 'extlib/grids/col_model'
require 'extlib/grids/selection_model'
require 'extlib/grids/grid_view'
require 'extlib/grids/plugin'
require 'extlib/grids/grid'
ActionController::Base.helper(ExtLib::Grids::GenerateJs)

# Button
require 'extlib/buttons/generate_js'
ActionController::Base.helper(ExtLib::Buttons::GenerateJs)

# Forms
require 'extlib/forms/generate_js'
ActionController::Base.helper(ExtLib::Forms::GenerateJs)

# Windows
require 'extlib/windows/generate_js'
ActionController::Base.helper(ExtLib::Windows::GenerateJs)

# Viewports
require 'extlib/viewports/generate_js'
ActionController::Base.helper(ExtLib::Viewports::GenerateJs)

# Other Components
require 'extlib/others/generate_js'
ActionController::Base.helper(ExtLib::Others::GenerateJs)


# Common
require 'extlib/coms'

# Base
ActionController::Base.helper(ExtLib)
