Ext.namespace("os");

os.WMSCapabilitiesLoader = Ext.extend(GeoExt.tree.WMSCapabilitiesLoader,{

  capabilitiesStore:null,
  infoFormat: null,
  exceptionFormat: null,

  /** api: config[url]
   *  ``String``
   *  The online resource of the Web Map Service.
   */
  url: null,

  /** api: config[layerOptions]z
   *  ``Object``
   *  Optional options to set on the WMS layers which will be created by
   *  this loader.
   */
  layerOptions: null,

  /** api: config[layerParams]
   *  ``Object``
   *  Optional parameters to set on the WMS layers which will be created by
   *  this loader.
   */
  layerParams: null,

  /** private: method[processResponse]
   *  :param response: ``Object`` The XHR object
   *  :param node: ``Ext.tree.TreeNode``
   *  :param callback: ``Function``
   *  :param scope: ``Object``
   *
   *  Private processResponse override.
   */
  processResponse : function(response, node, callback, scope){
    /*
     * NOTE: This causes IE to crash, as it recieves a malformed response.responseXML object.
     * The responseXML has a null documentElement, which chain-reactions into a crash.
     * Safer option is to parse the raw text.
     * ---
    var capabilities = new OpenLayers.Format.WMSCapabilities().read(
        response.responseXML || response.responseText);
     * ---
     */
    var capabilities = new OpenLayers.Format.WMSCapabilities().read(response.responseText);

    if (!capabilities.capability) {
      this.hasLayers = false;
      scope.loading = false;
    } else {
      this.hasLayers = true;
      this.capabilitiesStore = new GeoExt.data.WMSCapabilitiesStore({data:capabilities});

      // choose preferred info_format
      // not supported: application/vnd.esri.wms_raw_xml, application/vnd.esri.wms_featureinfo_xml
      var infoFormats = [];
      if (capabilities.capability.request.getfeatureinfo) {
        infoFormats = capabilities.capability.request.getfeatureinfo.formats;
      }

      var preferredInfoFormats = ["application/vnd.ogc.wms_xml", "text/xml", "application/vnd.ogc.gml", "text/html", "text/plain"];
      for (var format in preferredInfoFormats) {
        if (infoFormats.indexOf(format) > -1) {
          this.infoFormat = format;
          break;
        }
      }

      // Set the exception format for WMS interactions.
      var preferredExceptionFormats = ["application/vnd.ogc.se_xml", "XML", "text/xml"];
      var exceptionFormats = capabilities.capability.exception.formats;
      for (var format in preferredExceptionFormats) {
        if (exceptionFormats.indexOf(format) > -1) {
          this.exceptionFormat = format;
          break;
        }
      }

      this.processLayer(capabilities.capability,
        capabilities.capability.request.getmap.href, node);
      if (typeof callback == "function") {
        callback.apply(scope || node, [node]);
      }
    }
  },


  /** private: method[createWMSLayer]
   *  :param layer: ``Object`` The layer object from the WMS GetCapabilities
   *  parser
   *  :param url: ``String`` The online resource of the WMS
   *  :return: ``OpenLayers.Layer.WMS`` or ``null`` The WMS layer created or
   *  null.
   *
   *  Create a WMS layer which will be attached as an attribute to the
   *  node.
   */
  createWMSLayer: function(layer, url){
    if (layer.name) {
      //this.hasLayers = true;
      var newLayer = new OpenLayers.Layer.WMS(layer.title, url, OpenLayers.Util.extend({
        formats: layer.formats[0],
        layers: layer.name
      }, this.layerParams), OpenLayers.Util.extend({
        minScale: layer.minScale,
        queryable: layer.queryable,
        maxScale: layer.maxScale,
        //attribution: layer.attribution,
        metadata: layer
      }, this.layerOptions));
      if (layer.attribution)
      {
        if (layer.attribution.title) {
          newLayer.attribution = ""; //layer.attribution.title;
        } else {
          newLayer.attribution = ""; //layer.attribution;
        }
      }
      return newLayer;
    }
    else {
      return null;
    }
  },

  /** private: method[processLayer]
   *  :param layer: ``Object`` The layer object from the WMS GetCapabilities
   *  parser
   *  :param url: ``String`` The online resource of the WMS
   *  :param node: ``Ext.tree.TreeNode``
   *
   *  Recursive function to create the tree nodes for the layer structure
   *  of a WMS GetCapabilities response.
   */
  processLayer: function(layer, url, node){
    Ext.each(layer.nestedLayers, function(el){
      var lyr;
      if(el.name){
        var ndx = this.capabilitiesStore.findBy(function(rec){
          return el.name == rec.get('name') && el.title == rec.get('title') && el.prefix == rec.get('prefix');
        })
        if(ndx>-1){
          lyr = this.capabilitiesStore.getAt(ndx);
        }
      }
      var n = this.createNode({
        text: el.title || el.name,
        // use nodeType 'node' so no AsyncTreeNodes are created
        nodeType: 'node',
        layer: lyr,
        leaf: (el.nestedLayers.length === 0),

        expanded: true// Added for INSPIRE

      });
      if (n) {
        if (n.attributes.layer)
        {
          n.attributes.layer.data.INFO_FORMAT = this.infoFormat;
          n.attributes.layer.data.EXCEPTIONS = this.exceptionFormat;
          n.attributes.layer.data.layer = this.createWMSLayer(el, url);
        }
        node.appendChild(n);
      }
      if (el.nestedLayers) {
        this.processLayer(el, url, n);
      }
    }, this);
  },
  getHasLayers: function(){
    return this.hasLayers;
  }
});
