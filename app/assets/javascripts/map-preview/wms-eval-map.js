// Name: wms-eval-map.js
// Description: JavaScript file for the INSPIRE / UKLP evaluation map widget (evalmapwms.htm)
// Author: Peter Cotroneo, Ordnance Survey, Andrew Bailey (C)
// Version: 2.4.0.5
// Notes: This version does not turn layers off automatically after receiving an image load error
//        On deployment: change UKLP_HELP_DOCUMENTATION to suit DGU href

var tree, mapPanel, map, xmlHttp, leftPanel, activeLayersPanel, formPanel;
var infoPanel, checkboxes, overview;
var urls, reachableUrls, unreachableUrls;
var intervalID, bBoxErr;
var bBox;                                       // array to store the parsed parameters
var mapBounds;                                  // OpenLayers.Bounds of the parsed parameters
var mapExtent;                                  // OpenLayers.Bounds transformed to correct projection
var boxes;                                      // OpenLayers.Layer to store area of interest
var redBox;                                     // OpenLayers.Marker to store area of interest
var borderColor;
var clickControl;                               // OpenLayers.WMSGetFeatureInfo Control to handle get feature info requests
var hist;                                       // OpenLayers.NavigationHistory Control to handle forward & back navigation
var loadingPanel;                               // OpenLayers.Control.LoadingPanel to handle loading information
var myLayerURLs;                                // array to store URLs against each external map layer
var myLayers;                                   // array to store external map layers in map
var paramsParsed;                               // object that holds bounding box, urls and info Format / Exceptions format for testing
var copyrightStatements;                        // string to store OS & Gebco copyright statements
var previousZoom = 0;                           // integer holding previous zoom (used by map.zoomstart/zoomend)
var baseMappingPreferenceLargeScales = true;    // boolean holding preference for base mapping enablement
var unqueryables;

/*
 * Projection definitions
 */
Proj4js.defs["EPSG:4258"] = "+proj=longlat +ellps=GRS80 +no_defs";
Proj4js.defs["EPSG:27700"] = "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs";
Proj4js.defs["EPSG:29903"] = "+proj=tmerc +lat_0=53.5 +lon_0=-8 +k=1.000035 +x_0=200000 +y_0=250000 +a=6377340.189 +b=6356034.447938534 +units=m +no_defs";
Proj4js.defs["EPSG:2157"] = "+proj=tmerc +lat_0=53.5 +lon_0=-8 +k=0.99982 +x_0=600000 +y_0=750000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
Proj4js.defs["EPSG:4326"] = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";

//Proj4js.defs["EPSG:4258"] = "+proj=longlat +ellps=GRS80 +units=degrees +no_defs";
//Proj4js.defs["EPSG:4326"] = "+proj=longlat +ellps=WGS84 +datum=WGS84 +units=degrees +no_defs";

/* Tell OpenLayers which projections need reverseAxisOrder in WMS 1.3 */
OpenLayers.Layer.WMS.prototype.yx["EPSG:4258"] = true;

OpenLayers.Projection.defaults["EPSG:27700"]  = { yx: false };
OpenLayers.Projection.defaults["EPSG:29903"]  = { yx: false };
OpenLayers.Projection.defaults["EPSG:2157"]   = { yx: false };
OpenLayers.Projection.defaults["EPSG:4326"]   = { yx: false };

/* Provide a more informative default image for failed legendUrl requests */
//GeoExt.LegendImage.prototype.defaultImgSrc = "http://46.137.180.108/images/no_legend.png";

Ext.QuickTips.init();

var ActiveLayerNodeUI = Ext.extend(GeoExt.tree.LayerNodeUI, new GeoExt.tree.TreeNodeUIEventMixin());

Ext.onReady(function(){

    OSInspire = {};

    OSInspire.Layer = {};

    /**
     * Overrides for OpenLayers WMS map layer.
     * This layer interacts with Web Mapping Services, these are usually remote endpoints.
     * getURL function overrides default implementation for GetMap querystring on this layer.
     */
    OSInspire.Layer.WMS = OpenLayers.Class(OpenLayers.Layer.WMS, {
        getURL: function(bounds){
            bounds = this.adjustBounds(bounds);
            var imageSize = this.getImageSize();
            var newParams = {};
            // WMS 1.3 introduced axis order
            var reverseAxisOrder = this.reverseAxisOrder();
            newParams.BBOX = this.encodeBBOX ? bounds.toBBOX(null, reverseAxisOrder) : bounds.toArray(reverseAxisOrder);
            newParams.WIDTH = imageSize.w;
            newParams.HEIGHT = imageSize.h;
            newParams.LAYERS = this.layerNames[this.map.zoom];
            var requestString = this.getFullRequestString(newParams);
            return requestString;
        },
        CLASS_NAME: "OSInspire.Layer.WMS"
    });

    /**
     * Overrides how GetFeatureInfo responses are interpreted.
     */
    OSInspire.WMSGetFeatureInfo = OpenLayers.Class(OpenLayers.Format.WMSGetFeatureInfo, {
        read : function(data){
            if (typeof data == "object") {
                // possibly XML document
                if (data.doctype)
                {
                    // potentially to be an html doc disguised as xml
                    if (data.doctype.name)
                    {
                        switch (data.doctype.name)
                        {
                            case "html":
                                features = [new OpenLayers.Feature.Vector(null,{rawInfo:XMLtoString(data)})];   //
                                break;
                            default:
                                features = OpenLayers.Format.WMSGetFeatureInfo.prototype.read.call(this,data);
                        }
                    } else {
                        // process as xml
                        features = OpenLayers.Format.WMSGetFeatureInfo.prototype.read.call(this,data);
                    }
                } else {
                    // process as xml
                    features = OpenLayers.Format.WMSGetFeatureInfo.prototype.read.call(this,data);
                }
            } else {
                // not an XML document, but it might be an XML string. Attempt to process as XML first
                if (typeof data == "string") {
                    features = OpenLayers.Format.WMSGetFeatureInfo.prototype.read.call(this,data);
                    if(!features.length){
                       features = [new OpenLayers.Feature.Vector(null,{rawInfo:data})];
                    }
                }
            }
            return features;
        },
        CLASS_NAME: "OSInspire.WMSGetFeatureInfo"
    });

    OpenLayers.Control.LoadingPanel = OpenLayers.Class(OpenLayers.Control, {

        /**
         * Property: counter
         * {Integer} A counter for the number of layers loading
         */
        counter: 0,

        /**
         * Property: maximized
         * {Boolean} A boolean indicating whether or not the control is maximized
        */
        maximized: false,

        /**
         * Property: visible
         * {Boolean} A boolean indicating whether or not the control is visible
        */
        visible: true,

        /**
         * Constructor: OpenLayers.Control.LoadingPanel
         * Display a panel across the map that says 'loading'.
         *
         * Parameters:
         * options - {Object} additional options.
         */
        initialize: function(options) {
             OpenLayers.Control.prototype.initialize.apply(this, [options]);
        },

        /**
         * Function: setVisible
         * Set the visibility of this control
         *
         * Parameters:
         * visible - {Boolean} should the control be visible or not?
        */
        setVisible: function(visible) {
            this.visible = visible;
            if (visible) {
                OpenLayers.Element.show(this.div);
            } else {
                OpenLayers.Element.hide(this.div);
            }
        },

        getWaitText: function() {
            return ("Waiting for map services to load.");
        },

        /**
         * Function: getVisible
         * Get the visibility of this control
         *
         * Returns:
         * {Boolean} the current visibility of this control
        */
        getVisible: function() {
            return this.visible;
        },

        /**
         * APIMethod: hide
         * Hide the loading panel control
        */
        hide: function() {
            this.setVisible(false);
        },

        /**
         * APIMethod: show
         * Show the loading panel control
        */
        show: function() {
            this.setVisible(true);
        },

        /**
         * APIMethod: toggle
         * Toggle the visibility of the loading panel control
        */
        toggle: function() {
            this.setVisible(!this.getVisible());
        },

        /**
         * Method: addLayer
         * Attach event handlers when new layer gets added to the map
         *
         * Parameters:
         * evt - {Event}
        */
        addLayer: function(evt) {
            if (evt.layer) {
                evt.layer.events.register('loadstart', this, this.increaseCounter);
                evt.layer.events.register('loadend', this, this.decreaseCounter);
            }
        },

        /**
         * Method: setMap
         * Set the map property for the control and all handlers.
         *
         * Parameters:
         * map - {<OpenLayers.Map>} The control's map.
         */
        setMap: function(map) {
            OpenLayers.Control.prototype.setMap.apply(this, arguments);
            this.map.events.register('preaddlayer', this, this.addLayer);
            for (var i = 0; i < this.map.layers.length; i++) {
                var layer = this.map.layers[i];
                layer.events.register('loadstart', this, this.increaseCounter);
                layer.events.register('loadend', this, this.decreaseCounter);
            }
        },

        /**
         * Method: increaseCounter
         * Increase the counter and show control
        */
        increaseCounter: function() {
            this.counter++;
            if (this.counter > 0) {
                this.div.innerHTML = this.getWaitText();
                if (!this.maximized && this.visible) {
                    this.maximizeControl();
                }
            }
        },

        /**
         * Method: decreaseCounter
         * Decrease the counter and hide the control if finished
        */
        decreaseCounter: function() {
            if (this.counter > 0) {
                this.div.innerHTML = this.getWaitText();
                this.counter--;
            }
            if (this.counter == 0) {
                if (this.maximized && this.visible) {
                    this.minimizeControl();
                }
            }
        },

        /**
         * Method: draw
         * Create and return the element to be splashed over the map.
         */
        draw: function () {
            OpenLayers.Control.prototype.draw.apply(this, arguments);
            return this.div;
        },

        /**
         * Method: minimizeControl
         * Set the display properties of the control to make it disappear.
         *
         * Parameters:
         * evt - {Event}
         */
        minimizeControl: function(evt) {
            this.div.style.display = "none";
            this.maximized = false;

            if (evt != null) {
                OpenLayers.Event.stop(evt);
            }
        },

        /**
         * Method: maximizeControl
         * Make the control visible.
         *
         * Parameters:
         * evt - {Event}
         */
        maximizeControl: function(evt) {
            this.div.style.display = "block";
            this.maximized = true;

            if (evt != null) {
                OpenLayers.Event.stop(evt);
            }
        },

        /**
         * Method: destroy
         * Destroy control.
         */
        destroy: function() {
            if (this.map) {
                this.map.events.unregister('preaddlayer', this, this.addLayer);
                if (this.map.layers) {
                    for (var i = 0; i < this.map.layers.length; i++) {
                        var layer = this.map.layers[i];
                        layer.events.unregister('loadstart', this,
                            this.increaseCounter);
                        layer.events.unregister('loadend', this,
                            this.decreaseCounter);
                    }
                }
            }
            OpenLayers.Control.prototype.destroy.apply(this, arguments);
        },

        CLASS_NAME: "OpenLayers.Control.LoadingPanel"

    });

    OpenLayers.Control.NavigationHistorywProjection = OpenLayers.Class(OpenLayers.Control, {

        /**
         * Property: type
         * {String} Note that this control is not intended to be added directly
         *     to a control panel.  Instead, add the sub-controls previous and
         *     next.  These sub-controls are button type controls that activate
         *     and deactivate themselves.  If this parent control is added to
         *     a panel, it will act as a toggle.
         */
        type: OpenLayers.Control.TYPE_TOGGLE,

        /**
         * Property: boxbounds
         * {OpenLayers.Bounds} This version of the NavigationHistory control will
         *     take the bounds of the defined Search Criteria layer when it first
         *     comes into contact with it. This bounds will then be used in all
         *     future projection transformations. If this doesn't happen accuracy
         *     is lost on repeated transformations.
         */
        boxbounds: null,

        /**
         * Property: boxproj
         * {OopenLayers.Projection} This is the projection that is associated with the
         * boxbounds bounds property
         */
        boxproj: null,

        /**
         * APIProperty: previous
         * {<OpenLayers.Control>} A button type control whose trigger method restores
         *     the previous state managed by this control.
         */
        previous: null,

        /**
         * APIProperty: previousOptions
         * {Object} Set this property on the options argument of the constructor
         *     to set optional properties on the <previous> control.
         */
        previousOptions: null,

        /**
         * APIProperty: next
         * {<OpenLayers.Control>} A button type control whose trigger method restores
         *     the next state managed by this control.
         */
        next: null,

        /**
         * APIProperty: nextOptions
         * {Object} Set this property on the options argument of the constructor
         *     to set optional properties on the <next> control.
         */
        nextOptions: null,

        /**
         * APIProperty: limit
         * {Integer} Optional limit on the number of history items to retain.  If
         *     null, there is no limit.  Default is 50.
         */
        limit: 50,

        /**
         * APIProperty: autoActivate
         * {Boolean} Activate the control when it is added to a map.  Default is
         *     true.
         */
        autoActivate: true,

        /**
         * Property: clearOnDeactivate
         * {Boolean} Clear the history when the control is deactivated.  Default
         *     is false.
         */
        clearOnDeactivate: false,

        /**
         * Property: registry
         * {Object} An object with keys corresponding to event types.  Values
         *     are functions that return an object representing the current state.
         */
        registry: null,

        /**
         * Property: nextStack
         * {Array} Array of items in the history.
         */
        nextStack: null,

        /**
         * Property: previousStack
         * {Array} List of items in the history.  First item represents the current
         *     state.
         */
        previousStack: null,

        /**
         * Property: listeners
         * {Object} An object containing properties corresponding to event types.
         *     This object is used to configure the control and is modified on
         *     construction.
         */
        listeners: null,

        /**
         * Property: restoring
         * {Boolean} Currently restoring a history state.  This is set to true
         *     before calling restore and set to false after restore returns.
         */
        restoring: false,

        /**
         * Constructor: OpenLayers.Control.NavigationHistory
         *
         * Parameters:
         * options - {Object} An optional object whose properties will be used
         *     to extend the control.
         */
        initialize: function(options) {
            OpenLayers.Control.prototype.initialize.apply(this, [options]);

            this.registry = OpenLayers.Util.extend({
                "moveend": this.getState
            }, this.registry);

            var previousOptions = {
                trigger: OpenLayers.Function.bind(this.previousTrigger, this),
                displayClass: this.displayClass + " " + this.displayClass + "Previous"
            };
            OpenLayers.Util.extend(previousOptions, this.previousOptions);
            this.previous = new OpenLayers.Control.Button(previousOptions);

            var nextOptions = {
                trigger: OpenLayers.Function.bind(this.nextTrigger, this),
                displayClass: this.displayClass + " " + this.displayClass + "Next"
            };
            OpenLayers.Util.extend(nextOptions, this.nextOptions);
            this.next = new OpenLayers.Control.Button(nextOptions);

            this.clear();

        },

        /**
         * Method: onPreviousChange
         * Called when the previous history stack changes.
         *
         * Parameters:
         * state - {Object} An object representing the state to be restored
         *     if previous is triggered again or null if no previous states remain.
         * length - {Integer} The number of remaining previous states that can
         *     be restored.
         */
        onPreviousChange: function(state, length) {
            //console.log("onPreviousChange");
            if(state && !this.previous.active) {
                this.previous.activate();
            } else if(!state && this.previous.active) {
                this.previous.deactivate();
            }
        },

        /**
         * Method: onNextChange
         * Called when the next history stack changes.
         *
         * Parameters:
         * state - {Object} An object representing the state to be restored
         *     if next is triggered again or null if no next states remain.
         * length - {Integer} The number of remaining next states that can
         *     be restored.
         */
        onNextChange: function(state, length) {
            //console.log("onNextChange");
            if(state && !this.next.active) {
                this.next.activate();
            } else if(!state && this.next.active) {
                this.next.deactivate();
            }
        },

        /**
         * APIMethod: destroy
         * Destroy the control.
         */
        destroy: function() {
            OpenLayers.Control.prototype.destroy.apply(this);
            this.previous.destroy();
            this.next.destroy();
            this.deactivate();
            for(var prop in this) {
                this[prop] = null;
            }
        },

        /**
         * Method: setMap
         * Set the map property for the control and <previous> and <next> child
         *     controls.
         *
         * Parameters:
         * map - {<OpenLayers.Map>}
         */
        setMap: function(map) {
            this.map = map;
            this.next.setMap(map);
            this.previous.setMap(map);
        },

        /**
         * Method: draw
         * Called when the control is added to the map.
         */
        draw: function() {
            OpenLayers.Control.prototype.draw.apply(this, arguments);
            this.next.draw();
            this.previous.draw();
        },

        /**
         * Method: previousTrigger
         * Restore the previous state.  If no items are in the previous history
         *     stack, this has no effect.
         *
         * Returns:
         * {Object} Item representing state that was restored.  Undefined if no
         *     items are in the previous history stack.
         */
        previousTrigger: function() {
            //console.log("previousTrigger");
            var current = this.previousStack.shift();
            var state = this.previousStack.shift();
            if(state != undefined) {
                this.nextStack.unshift(current);
                this.previousStack.unshift(state);
                this.restoring = true;
                this.restore(state);
                this.restoring = false;
                this.onNextChange(this.nextStack[0], this.nextStack.length);
                this.onPreviousChange(
                    this.previousStack[1], this.previousStack.length - 1
                );
            } else {
                this.previousStack.unshift(current);
            }
            return state;
        },

        /**
         * APIMethod: nextTrigger
         * Restore the next state.  If no items are in the next history
         *     stack, this has no effect.  The next history stack is populated
         *     as states are restored from the previous history stack.
         *
         * Returns:
         * {Object} Item representing state that was restored.  Undefined if no
         *     items are in the next history stack.
         */
        nextTrigger: function() {
            //console.log("nextTrigger");
            var state = this.nextStack.shift();
            if(state != undefined) {
                this.previousStack.unshift(state);
                this.restoring = true;
                this.restore(state);
                this.restoring = false;
                this.onNextChange(this.nextStack[0], this.nextStack.length);
                this.onPreviousChange(
                    this.previousStack[1], this.previousStack.length - 1
                );
            }
            return state;
        },

        /**
         * APIMethod: clear
         * Clear history.
         */
        clear: function() {
            this.previousStack = [];
            this.previous.deactivate();
            this.nextStack = [];
            this.next.deactivate();
        },

        /**
         * Method: getState
         * Get the current state and return it.
         *
         * Returns:
         * {Object} An object representing the current state.
         */
        getState: function() {
            // populate boxbounds
            if (!(this.boxbounds))
            {
                for (var i = 0, len = this.map.layers.length; i < len; i++) {
                    if (this.map.layers[i].name == "Search Criteria") {
                        if (this.map.layers[i].visibility == true)
                        {
                            // find first feature's bounds
                            this.boxbounds = this.map.layers[i].markers[0].bounds.clone();
                        }
                    }
                }
                this.boxproj = new OpenLayers.Projection(this.map.getProjectionObject().getCode());
            }

            return {
                zoom: this.map.getZoom(),
                center: this.map.getCenter(),
                projection: this.map.getProjectionObject(),
                resolution: this.map.getResolution(),
                units: this.map.getProjectionObject().getUnits() ||
                    this.map.units || this.map.baseLayer.units
            };
        },

        /**
         * Method: restore
         * Update the state with the given object.
         *
         * Parameters:
         * state - {Object} An object representing the state to restore.
         */
        restore: function(state) {
            var center, zoom;
            // build options for map
            var options4258 = {
                // proper bounds for ETRS89
                maxExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
                restrictedExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
                projection: "EPSG:4258",
                units: "degrees"
            };
            var options4326 = {
                // bounds for WGS84
                maxExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
                restrictedExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
                projection: "EPSG:4326",
                units: "degrees"
            };
            var options27700 = {
                // proper bounds for BNG
                maxExtent: new OpenLayers.Bounds(-1676863.69127, -211235.79185, 810311.58692, 1870908.806),
                restrictedExtent: new OpenLayers.Bounds(-1676863.69127, -211235.79185, 810311.58692, 1870908.806),
                projection: "EPSG:27700",
                units: "m"
            };
            var options2157 = {
                // proper bounds for ITM
                maxExtent: new OpenLayers.Bounds(-1036355.59295, 138271.94508, 1457405.79374, 2105385.88137),
                restrictedExtent: new OpenLayers.Bounds(-1036355.59295, 138271.94508, 1457405.79374, 2105385.88137),
                projection: "EPSG:2157",
                units: "m"
            };
            var options29903 = {
                // proper bounds for IG
                maxExtent: new OpenLayers.Bounds(-1436672.42532, -361887.06768, 1057647.39762, 1605667.48446),
                restrictedExtent: new OpenLayers.Bounds(-1436672.42532, -361887.06768, 1057647.39762, 1605667.48446),
                projection: "EPSG:29903",
                units: "m"
            };
            var currentProj;

            if (this.map.getProjectionObject() == state.projection) {
                zoom = this.map.getZoomForResolution(state.resolution);
                center = state.center;
                this.map.setCenter(center, zoom);
            } else {
                currentProj = this.map.getProjectionObject();
                var triggerMoveEnd = false;
                if (((currentProj.getCode() == "EPSG:4326") || (currentProj.getCode() == "EPSG:4258")) &&
                    ((state.projection.getCode() == "EPSG:4326") || (state.projection.getCode() == "EPSG:4258"))) {
                        triggerMoveEnd = true;
                }
                // set baselayer
                var baseLayerForProjectionCode = 'InspireETRS89';
                var optionsForProjectionCode = options4258;
                var layersForProjectionCode = 'sea_dtm,overview_layers';

                switch (state.projection.getCode()) {
                    case "EPSG:4326":
                        baseLayerForProjectionCode = 'InspireWGS84';
                        layersForProjectionCode = 'sea_dtm_4326,overview_layers';
                        optionsForProjectionCode = options4326;
                        break;
                    case "EPSG:27700":
                        baseLayerForProjectionCode = 'InspireBNG';
                        layersForProjectionCode = 'sea_dtm_27700,overview_layers';
                        optionsForProjectionCode = options27700;
                        break;
                    case "EPSG:29903":
                        baseLayerForProjectionCode = 'InspireIG';
                        layersForProjectionCode = 'sea_dtm_29903,overview_layers';
                        optionsForProjectionCode = options29903;
                        break;
                    case "EPSG:2157":
                        baseLayerForProjectionCode = 'InspireITM';
                        layersForProjectionCode = 'sea_dtm_2157,overview_layers';
                        optionsForProjectionCode = options2157;
                        break;
                }

                this.map.baseLayer.mergeNewParams({ LAYERS: baseLayerForProjectionCode });
                OpenLayers.Util.extend(this.map, optionsForProjectionCode);
                // reset layers
                for (var i = 0, len = this.map.layers.length; i < len; i++) {
                    this.map.layers[i].addOptions(optionsForProjectionCode);
                    if (this.map.layers[i].name == "Search Criteria") {
                        if (this.map.layers[i].visibility == true)
                        {
                            // if boxbounds isn't present extract marker from layer
                            if (this.boxbounds) {
                                var markerExtent = this.boxbounds.clone();
                                markerExtent.transform(this.boxproj, state.projection);
                            } else {
                                // find first feature's bounds
                                var markerExtent = this.map.layers[i].markers[0].bounds.clone();
                                // transform bounds
                                markerExtent.transform(currentProj, state.projection);
                            }
                            // remove feature
                            this.map.layers[i].clearMarkers();
                            // create feature
                            this.map.layers[i].addMarker(new OpenLayers.Marker.Box(markerExtent, "red"));
                            // redraw - possibly
                            this.map.layers[i].redraw();
                        }

                    }
                }

                var ov = this.map.getControlsByClass("OpenLayers.Control.OverviewMap");
                if (ov.length > 0) {
                    ov[0].ovmap.baseLayer.mergeNewParams({
                        LAYERS: layersForProjectionCode
                    });
                    for (var i = 0; i < ov[0].ovmap.layers.length; i++) {
                        ov[0].ovmap.layers[i].addOptions(optionsForProjectionCode);
                    }
                    ov[0].ovmap.setOptions(optionsForProjectionCode);
                }

                // centre map
                center = state.center.clone();
                zoom = state.zoom;
                this.map.moveTo(center);
                this.map.setCenter(center, zoom, true, true);
                if (triggerMoveEnd) {
                    this.map.events.triggerEvent("moveend");
                }

            }
        },

        /**
         * Method: setListeners
         * Sets functions to be registered in the listeners object.
         */
        setListeners: function() {
            this.listeners = {};
            for(var type in this.registry) {
                this.listeners[type] = OpenLayers.Function.bind(function() {
                    if(!this.restoring) {
                        var state = this.registry[type].apply(this, arguments);
                        this.previousStack.unshift(state);
                        if(this.previousStack.length > 1) {
                            this.onPreviousChange(
                                this.previousStack[1], this.previousStack.length - 1
                            );
                        }
                        if(this.previousStack.length > (this.limit + 1)) {
                            this.previousStack.pop();
                        }
                        if(this.nextStack.length > 0) {
                            this.nextStack = [];
                            this.onNextChange(null, 0);
                        }
                    }
                    return true;
                }, this);
            }
        },

        /**
         * APIMethod: activate
         * Activate the control.  This registers any listeners.
         *
         * Returns:
         * {Boolean} Control successfully activated.
         */
        activate: function() {
            var activated = false;
            if(this.map) {
                if(OpenLayers.Control.prototype.activate.apply(this)) {
                    if(this.listeners == null) {
                        this.setListeners();
                    }
                    for(var type in this.listeners) {
                        this.map.events.register(type, this, this.listeners[type]);
                    }
                    activated = true;
                    if(this.previousStack.length == 0) {
                        this.initStack();
                    }
                }
            }
            return activated;
        },

        /**
         * Method: initStack
         * Called after the control is activated if the previous history stack is
         *     empty.
         */
        initStack: function() {
            if(this.map.getCenter()) {
                this.listeners.moveend();
            }
        },

        /**
         * APIMethod: deactivate
         * Deactivate the control.  This unregisters any listeners.
         *
         * Returns:
         * {Boolean} Control successfully deactivated.
         */
        deactivate: function() {
            var deactivated = false;
            if(this.map) {
                if(OpenLayers.Control.prototype.deactivate.apply(this)) {
                    for(var type in this.listeners) {
                        this.map.events.unregister(
                            type, this, this.listeners[type]
                        );
                    }
                    if(this.clearOnDeactivate) {
                        this.clear();
                    }
                    deactivated = true;
                }
            }
            return deactivated;
        },

        CLASS_NAME: "OpenLayers.Control.NavigationHistorywProjection"
    });

    OpenLayers.DOTS_PER_INCH = 90.71428571428572;

    OpenLayers.ProxyHost = "preview_getinfo?url=";

    OpenLayers.Util.onImageLoadError = function(){

        //now defunct OpenLayers.Util.onImageLoadError

        // this.src provides the wms request
        var errorStr = this.src.substring(0, (this.src.indexOf("?") + 1));
        var childStr = "";

        var foundBadWMS = false;
        var root = tree.getRootNode();
        var children = root.childNodes;

        if (!(foundBadWMS)) {
            // src may be returning with a different sub-domain but the same parent domain/hostname
            errorStr = getHostname(this.src);
            var count = errorStr.split(".");
            if (count.length > 2) {
                // www.xxx.com counts the same as yyy.xxx.com
                var parentDomain = errorStr.substring((errorStr.indexOf(".") + 1), errorStr.length);
                for (var j = 0; j < children.length; j++) {
                    parentDomainOfNode = getHostname(children[j].text);
                    parentDomainOfNode = parentDomainOfNode.substring((parentDomainOfNode.indexOf(".") + 1), parentDomainOfNode.length);
                    if (parentDomain == parentDomainOfNode) {
                        Ext.MessageBox.alert('Error', ("The WMS source: " + children[j].text + " has failed to load - please switch it off or try a different projection."));
                        foundBadWMS = true;
                    }
                }
            }
        }
    }

    var options = {
        projection: "EPSG:4258",
        units: 'degrees',
        maxExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        scales: [15000000, 10000000, 5000000, 1000000, 250000, 75000, 50000, 25000, 10000, 5000, 2500,1000],
        restrictedExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
        tileSize: new OpenLayers.Size(250, 250),
        controls: [
                new OpenLayers.Control.Navigation({documentDrag: true, zoomWheelEnabled: true}),
                new OpenLayers.Control.PanZoom(),
                new OpenLayers.Control.ArgParser(),
                new OpenLayers.Control.Attribution()
            ]
    };

    copyrightStatements = "Contains Ordnance Survey data (c) Crown copyright and database right [2012].<br>" +
    "Contains Royal Mail data (c) Royal Mail copyright and database right [2012]<br>" +
    "Contains bathymetry data by GEBCO (c) Copyright [2012].<br>" +
    "Contains data by Land & Property Services (Northern Ireland) (c) Crown copyright [2012]";

    tiled = new OpenLayers.Layer.WMS("OS Base Mapping", CKANEXT_OS_TILES_URL, {
        LAYERS: 'InspireETRS89',
        styles: '',
        format: 'image/png',
        tiled: true
    }, {
        buffer: 0,
        displayOutsideMaxExtent: true,
        isBaseLayer: true,
        attribution: copyrightStatements,
        transitionEffect: 'resize',
        queryable: false
    });

    var wmsParams = {
        format: 'image/png'
    };

    var wmsOptions = {
        buffer: 0,
        attribution: copyrightStatements
    };

    map = new OpenLayers.Map("mappanel", options);

    map.events.on({
        "zoomend": function(e){
            var chxBaseMap = Ext.getCmp('checkboxes').items.get(0);

            if (map.getNumLayers() > 0)
            {
                if (map.getZoom() > 8)
                {
                    // map zoom 9, 10 or 11 - base mapping off and disabled
                    chxBaseMap.setValue(false);
                    chxBaseMap.disable();
                    baseMappingOn(false);
                } else {
                    // map zoom 1 - 8 - base mapping enabled
                    chxBaseMap.enable()
                    // turn base mapping on if preference
                    if (baseMappingPreferenceLargeScales)
                    {
                        chxBaseMap.setValue(true);
                    } else {
                        chxBaseMap.setValue(false);
                    }
                }
            }
        }
    });
    map.events.on({
        "movestart": function(e){
            Ext.getCmp('checkboxes').items.get(0).focus();
            previousZoom = map.getZoom();
            if (previousZoom < 9)
            {
                baseMappingPreferenceLargeScales = Ext.getCmp('checkboxes').items.get(0).getValue();
            }
        }
    });
    map.events.on({
        "moveend": function(e){
            // activeLayerPanel's sliders can take control of key presses after the map has 'focus'
            Ext.each(activeLayersPanel.getRootNode().childNodes, function(node)
            {
                if (node.isSelected())
                {
                    node.unselect();
                }
            });
            // check that projection combo box is displaying correct value
            var cbxValue;
            var combo = Ext.ComponentMgr.get("projectionCombo");
            switch (combo.getValue()) {
                case "ETRS89":
                    cbxValue = "EPSG:4258";
                    break;
                case "WGS84":
                    cbxValue = "EPSG:4326";
                    break;
                case "British National Grid":
                    cbxValue = "EPSG:27700";
                    break;
                case "Irish Grid":
                    cbxValue = "EPSG:29903";
                    break;
                case "Irish Transverse Mercator":
                    cbxValue = "EPSG:2157";
                    break;
                default:
                    cbxValue = "EPSG:4258";
            }
            if(map.getProjectionObject().getCode() != cbxValue)
            {
                switch (map.getProjectionObject().getCode()) {
                    case "EPSG:4258":
                        combo.setValue("ETRS89");
                        break;
                    case "EPSG:4326":
                        combo.setValue("WGS84");
                        break;
                    case "EPSG:27700":
                        combo.setValue("British National Grid");
                        break;
                    case "EPSG:29903":
                        combo.setValue("Irish Grid");
                        break;
                    case "EPSG:2157":
                        combo.setValue("Irish Transverse Mercator");
                        break;
                    default:
                        // console.log("Coordinate system not recognized");
                }
            }
        }
    });
    map.events.on({
        "addlayer": function(e){
            var topPosition = map.getNumLayers() - 1;
            var arrBoxes = map.getLayersByName("Search Criteria");
            if (arrBoxes.length > 0) {
                map.setLayerIndex(arrBoxes[0], topPosition);
            }
        }
    });

    // overview layer
    var overviewLayer = new OpenLayers.Layer.WMS("Geoserver layers - nonTiled", CKANEXT_OS_WMS_URL, {
        LAYERS: 'sea_dtm,overview_layers',
        STYLES: '',
        format: 'image/png',
        tiled: false
    });

    //create overview map options
    var overviewOptions = {
        maximized: true,
        minRatio: 16,
        theme: null,
        title: "Overview Map. Use the + or - buttons to maximize or minimize the Overview Map",
        mapOptions: {
            numZoomLevels: 1,
            fallThrough: false,
            maxExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
            restrictedExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
            tileSize: new OpenLayers.Size(250, 250),
            units: 'degrees',
            projection: "EPSG:4258"
        },
        layers: [overviewLayer]
    }

    //create overview map
    overview = new OpenLayers.Control.OverviewMap(overviewOptions);
    map.addControl(overview);

    // The OpenLayers.Control.Click object is used as a workaround to a known bug in OpenLayers
    // Right-click on map and left-click can stop working
    // We use a click control to grab the right-click and bump the getFeatureInfo control into life
    OpenLayers.Control.Click = OpenLayers.Class(OpenLayers.Control, {
        defaultHandlerOptions: {
            'single': true,
            'double': true,
            'pixelTolerance': null,
            'stopSingle': false,
            'stopDouble': false
        },
        handleRightClicks:true,
        initialize: function(options) {
            this.handlerOptions = OpenLayers.Util.extend(
                {}, this.defaultHandlerOptions
            );
            OpenLayers.Control.prototype.initialize.apply(this, arguments);
            this.handler = new OpenLayers.Handler.Click(
                this, this.eventMethods, this.handlerOptions
            );
        },
        CLASS_NAME: "OpenLayers.Control.Click"
    });
    // Add an instance of the Click control that listens to various click events:
    var oClick = new OpenLayers.Control.Click({eventMethods:{
        'rightclick': function(e) {
            clickControl.deactivate();
            clickControl.activate();
        }
    }});
    map.addControl(oClick);
    oClick.activate();

    // XMLtoString - handling of getFeatureInfo responses
    function XMLtoString(elem){
        // used by clickControlFormat when receiving an html file that's recognised as an XML Document
        var serialized;
        try {
            // XMLSerializer exists in current Mozilla browsers
            serializer = new XMLSerializer();
            serialized = serializer.serializeToString(elem);
        }
        catch (e) {
            // Internet Explorer has a different approach to serializing XML
            serialized = elem.xml;
        }
        return serialized;
    }

    // handling of getFeatureInfo responses
    function boolCheckForContent(strinput){
        // checks for content against various response types
        // function is not processing content, just checking for existence
        // function could be extended further to accomodate processing

        // check for content from a FeatureInfoResponse - case 1
        // <FeatureInfoResponse...>..</FeatureInfoResponse>

        // check for content from a FeatureInfoResponse - case 2
        // <FeatureInfoResponse...>

        // check for content from a msGMLOutput - case 3
        // <msGMLOutput...>..</msGMLOutput>

        // check for content from a FeatureInfo - case 4
        // <FeatureInfo>..</FeatureInfo>

        // check for content from a GML response
        // <wfs:FeatureCollection...></wfs:FeatureCollection>
        // should contain <gml:featureMember>

        // check for content from an HTML response
        // <body>
        var boolContent = false;
        var strInput = strinput.replaceAll("\r", "").replaceAll("\n","");
        // check for plain text: we're going to assume the presence of > and < means input is XML of some kind
        // we should use an XML validator here
        if ((strInput.indexOf("<") > -1 ) && (strInput.indexOf(">") > -1)) {
            if (strInput.indexOf("<body") > -1) {
                boolContent = true;
            } else {
                if (strInput.indexOf("<FeatureInfo") > -1) {
                    if (strInput.indexOf("<FeatureInfoResponse") > -1) {
                        // either
                        if (strInput.indexOf("</FeatureInfoResponse>") > -1) {
                            // <FeatureInfoResponse...>..</FeatureInfoResponse>
                            if (Math.abs(strInput.indexOf(">",strInput.indexOf("<FeatureInfoResponse")) - strInput.indexOf("</FeatureInfoResponse")) != 1) {
                                boolContent = true;
                            }
                        } else {
                            // <FeatureInfoResponse...>
                            // example: <?xml version="1.0"?> <FeatureInfoResponse xmlns:esri_wms="http://www.esri.com/wms" xmlns="http://www.esri.com/wms">
                            // a populated FeatureInfoResponse from esri should contains FIELDS
                            if (strInput.indexOf("FIELDS") != -1) {
                                boolContent = true;
                            }
                        }
                    } else {
                        // <FeatureInfo>..</FeatureInfo>
                        if (Math.abs(strInput.indexOf(">",strInput.indexOf("<FeatureInfo")) - strInput.indexOf("</FeatureInfo")) != 1) {
                            boolContent = true;
                        }
                    }
                } else {
                    if (strInput.indexOf("<msGMLOutput") > -1) {
                        // <msGMLOutput...>..</msGMLOutput>
                        if (Math.abs(strInput.indexOf(">", strInput.indexOf("msGMLOutput")) - strInput.indexOf("</msGMLOutput")) != 1) {
                            boolContent = true;
                        }
                    } else {
                        if (strInput.indexOf("<wfs:FeatureCollection") > -1) {
                            // should contain <gml:featureMember>
                            if (strInput.indexOf("<gml:featureMember>") > -1) {
                                boolContent = true;
                            }
                        }
                    }
                }
            }
        } else {
            // assumption has been made this is plain text
            if (strInput.length > 0)
            {
                boolContent = true;
            }
        }
        return boolContent;
    }

    // handling of getFeatureInfo responses
    function alphaNumericCheck(theChar) {
        // used by boolCheckForHTMLContent
        var cc = theChar.charCodeAt(0);
        if((cc>47 && cc<58) || (cc>64 && cc<91) || (cc>96 && cc<123))
        {
            return true;
        } else {
            return false;
        }
    }

    // format control for WMSGetFeatureInfo requests
    var clickControlFormat = new OSInspire.WMSGetFeatureInfo();

    // column model for grids - now defunct because of delivering all info requests in html tables
    var colModel = new Ext.grid.ColumnModel([
        {header: "Name", width:50, sortable: true, dataIndex:'name', id: 'name', menuDisabled:true},
        {header: "Value", width:500, resizable:true, dataIndex: 'value', id: 'value', menuDisabled:true,
            renderer : function(value, metadata, record) {
                return "<p style=\"white-space: normal;word-wrap:break-word;\">" + value + "</p>";
        }}
     ]);

    clickControl = new OpenLayers.Control.WMSGetFeatureInfo({
        drillDown: true,
        autoActivate: true,
        maxFeatures: 11,
        output: 'features', // object or features
        format: clickControlFormat,
        layers: [],
        handlerOptions: {
            "click": {delay: 1000}
        },
        eventListeners: {

            beforegetfeatureinfo: function(e) {
                // to stop sending getFeatureInfo requests to WMS layers that are not queryable
                // we have to run through each layer, if it is queryable then add it to the list
                // to be queried. Also add the layer's url to the url list.

                // also need to build url (string) and layerUrls (array string)
                unqueryables = new Array();
                // empty the layerUrls & layers array
                this.layerUrls.length = 0;
                this.layers.length = 0;
                this.url = "";

                // loop through map.layers ignoring base layers and top layer (boxes)
                for (var i = 1, len = this.map.layers.length; i < (len -1); i++) {
                    if (this.map.layers[i].queryable) {
                        //console.log("queryable: " + this.map.layers[i].name);
                        this.layers.push(this.map.layers[i]);
                        var layerUrlIsPresent = false;
                        for (var j = 0; j < this.layerUrls.length; j++) {
                            if (this.map.layers[i].url == this.layerUrls[j]) {
                                layerUrlIsPresent = true;
                            }
                        }
                        if (!(layerUrlIsPresent)) {
                            this.layerUrls.push(this.map.layers[i].url);
                        }
                    } else {
                        //console.log("not queryable: " + this.map.layers[i].name);
                        unqueryables.push(this.map.layers[i].name);
                    }
                }
                if (this.layerUrls.length > 0) {
                    this.url = this.layerUrls[0];
                }
            },

            nogetfeatureinfo: function(e) {
                if (unqueryables.length != 0) {
                    // no features to display, layers that have been selected are unqueryable
                    if (unqueryables.length > 1) {
                        Ext.MessageBox.alert('Feature Information', 'The selected layers do not support information retrieval.','');
                    } else {
                        Ext.MessageBox.alert('Feature Information', 'The selected layer does not support information retrieval.','');
                    }
                } else {
                Ext.MessageBox.alert('Feature Information', 'A layer must be selected before information can be retrieved.', '');
                }
            },

            getfeatureinfo: function(e) {
                if (!(Ext.isEmpty(Ext.getCmp('popup')))) {
                    popup.close();
                }
                var items = [];
                var propertyGridCount = 0;
                if (e.features.length == 0) {
                    // no features have been returned
                    // check for ServiceException
                    // check for content
                    if (e.text != null) {
                        if (e.text.toLowerCase().indexOf("serviceexception") > -1) {
                            var seXMLDoc = StringtoXML(e.text);
                            var dq = Ext.DomQuery;
                            var node = dq.selectNode('ServiceException', seXMLDoc);
                            var strServiceExceptionMessage;
                            if (node.textContent) {
                                strServiceExceptionMessage = node.textContent;
                            } else {
                                strServiceExceptionMessage = node.text;
                            }
                            items.push({
                                xtype: "panel",
                                title: "Layer response",
                                html: strServiceExceptionMessage,
                                autoScroll: true
                            });
                        } else {
                            var content = e.text;
                            if (!(boolCheckForContent(content))) {
                                // content is missing
                                content = "No feature information returned.";
                            } else {
                                // content is present
                                content = "Feature information returned:<br>" + e.text;
                            }
                            items.push({
                                xtype: "panel",
                                title: "Layer response",
                                html: content,
                                autoScroll: true
                            });
                        }
                    }
                } else {
                    // features have been returned, process them
                    for (i = 0; i < e.features.length; i++)
                    {
                        if (i < 10) {
                            if (e.features[i].data.rawInfo) {
                                // Feature has returned with rawInfo rather than nice attributes
                                // rawInfo could be XML, GML, HTML or Text + unsupported schemas
                                // We check that content is present otherwise notify user
                                var content = e.features[i].data.rawInfo;
                                if (!(boolCheckForContent(content))) {
                                    // content is missing
                                    content = "No feature information returned.";
                                } else {
                                    // content is present
                                    content = "Feature information returned:<br>" + e.features[i].data.rawInfo;
                                }
                                items.push({
                                    xtype: "panel",
                                    title: "Layer response",
                                    html: content,
                                    autoScroll: true
                                });
                            } else {
                                // could be an empty rawInfo string
                                if ("" + e.features[i].data.rawInfo != "undefined") {
                                    items.push({
                                        xtype: "panel",
                                        title: "Layer response",
                                        html: "No feature information returned.",
                                        autoScroll: true
                                    });
                                } else {
                                    // Feature has attributes which are easily handled
                                    var layerName = "";
                                    if (e.features[i].type) {
                                        layerName = ": " + e.features[i].type;
                                        layerName = layerName.replaceAll("."," ");
                                        layerName = layerName.replaceAll("_"," ");
                                    }
                                    propertyGridCount++;
                                    // Use html version with panel
                                    items.push({
                                        xtype: "panel",
                                        title: "Feature " + propertyGridCount + layerName,
                                        html: featuresAttributestoHTMLTable(e.features[i]),
                                        autoScroll: true
                                    });
                                }
                            }
                        }
                        if ((i == 10) && (e.features.length > 10))
                        {
                            items.push({
                                xtype: "panel",
                                title: "Other responses",
                                html: "Information is limited to 10 features. Please zoom in or reduce the number of layers that are visible.",
                                autoScroll: true
                            });
                        }
                    }
                }
                // calculating the anchor point for the popup
                var mapCentre = mapPanel.map.getCenter();
                // determine height required for popUp. There's a limit of 10 features + 1 warning of too many features = 11
                var popUpHeight;
                var featuresCount = e.features.length;
                if (featuresCount > 10) {
                    featuresCount = 11;
                }
                popUpHeight = (featuresCount * 25) + 105;
                if (popUpHeight < 300)
                {
                    popUpHeight = 300;
                }
                var popUpWidth = 400;
                // the following provides the bottom-left latlon point for the popup. no idea why it doesn't need -((popUpWidth/2)*mapPanel.map.getResolution()) on the lat but it works.
                var popUpAnchor = new OpenLayers.LonLat((mapCentre.lon),(mapCentre.lat-((popUpHeight/2)*mapPanel.map.getResolution())));

                // check for any returns
                if (items.length == 0) {
                    // add No Features returned message
                    items.push({
                        xtype: "panel",
                        title: "Feature Information",
                        html: "No features found.",
                        autoScroll: true
                    });
                }

                // check for any non-queryable layers
                if (unqueryables.length != 0) {
                    // non-queryable layers were skipped, tell user
                    items.push({
                        xtype: "panel",
                        title: "Non-queryable Layers",
                        html: ("The following layer(s) do not support information retrieval: " + unqueryables.toString()),
                        autoScroll: true
                    });
                }

                popup = new Ext.Window({
                    id: 'popup',
                    title: "Feature Information",
                    resizable: true,
                    width:popUpWidth,
                    height:popUpHeight,
                    minWidth: 400,
                    boxMaxWidth: 600,
                    layout: "accordion",
                    draggable: true,
                    constrain: true,
                    items: items
                });

                popup.show();
                OpenLayers.Element.removeClass(this.map.viewPortDiv, "olCursorWait");
                window.status="";
            }
        }
    });

    map.addControl(clickControl);

    // Remove default PanZoom bar; will use zoom slider below
    var ccControl = map.getControlsByClass("OpenLayers.Control.PanZoom");
    map.removeControl(ccControl[0]);

    // Add scale bar
    map.addControl(new OpenLayers.Control.ScaleLine({
        geodesic: false
    }));

    // keyboard control
    map.addControl(new OpenLayers.Control.KeyboardDefaults({
        autoActivate: true
    }));

    // Add mouse position.
    function formatLonlats(lonLat){
        var lat = lonLat.lat;
        var lon = lonLat.lon;
        var ns = OpenLayers.Util.getFormattedLonLat(lat);
        var ew = OpenLayers.Util.getFormattedLonLat(lon, 'lon');
        return ns + ', ' + ew + ' (' + (lat.toFixed(5)) + ', ' + (lon.toFixed(5)) + ')';
    }

    map.addControl(new OpenLayers.Control.MousePosition({
        formatOutput: formatLonlats
    }));

    // Add loading panel
    loadingPanel = new OpenLayers.Control.LoadingPanel();
    map.addControl(loadingPanel);

    //Add navigation history
    hist = new OpenLayers.Control.NavigationHistorywProjection();
    map.addControl(hist);

    //zoom to full extent
    function fullExtentClicked(){
        map.zoomToMaxExtent();
    }

    //navigation history buttons; previous, full extent and next
    var previousButton = new OpenLayers.Control.Button ({displayClass: 'previousButton', trigger: hist.previous.trigger, title: 'Go to previous map state'});
    var fullExtentButton = new OpenLayers.Control.Button ({displayClass: 'fullExtentButton', trigger: fullExtentClicked, title: 'Zoom to max extent'});
    var nextButton = new OpenLayers.Control.Button ({displayClass: 'nextButton', trigger: hist.next.trigger, title: 'Go to next map state'});

    //Map panel containing buttons
    panel = new OpenLayers.Control.Panel();
    panel.addControls([previousButton, fullExtentButton, nextButton]);
    map.addControl(panel);

    //Register events for buttons
    hist.previous.events.register("activate");
    hist.next.events.register("activate");

    // Create arrays
    reachableUrls = new Array();
    unreachableUrls = new Array();
    children = new Array();
    urls = new Array();
    // Build array of URLs
    for (i = 0; i < paramParser.getUrls().length; i++) {
        urls[i] = paramParser.getUrls()[i];
    }

    // ### Bounding box
    boxes = new OpenLayers.Layer.Boxes("Search Criteria");
    borderColor = "red";
    // Extract bounding box and bounds before AJAX call
    paramsParsed = paramParser;
    bBox = new Array(paramParser.getBBox().westBndLon, paramParser.getBBox().eastBndLon, paramParser.getBBox().northBndLat, paramParser.getBBox().southBndLat)

    // Add the default layers and make sure they're not included in getFeatureInfo requests
    tiled.queryable = false;
    boxes.queryable = false;
    map.addLayer(tiled);
    map.addLayer(boxes);

    // Bounding box logic
    if ((paramParser.getBBox().westBndLon == null) || (paramParser.getBBox().eastBndLon == null) || (paramParser.getBBox().southBndLat == null) || (paramParser.getBBox().northBndLat == null)) {
        // bounding box hasn't been passed
        bBoxErr = 1;
    } else {
        if (isNaN(paramParser.getBBox().westBndLon) || isNaN(paramParser.getBBox().eastBndLon) || isNaN(paramParser.getBBox().southBndLat) || isNaN(paramParser.getBBox().northBndLat)) {
            // bounding box hasn't been passed
            bBoxErr = 1;
        } else {
            if (paramParser.getBBox().westBndLon < -30.00 || paramParser.getBBox().eastBndLon > 3.50 || paramParser.getBBox().southBndLat < 48.00 || paramParser.getBBox().northBndLat > 64.00) {
                // failed parsed box paramters - need to generate a default mapBounds & mapExtent
                //Ext.MessageBox.alert('Error', 'The coordinates of the bounding box are outside of the searchable map bounds.', '');
                bBoxErr = 1;
            } else {
                if (paramParser.getBBox().westBndLon > paramParser.getBBox().eastBndLon) {
                    // failed parsed box paramters - need to generate a default mapBounds & mapExtent
                    //Ext.MessageBox.alert('Error', 'The west bounding longitude cannot be greater than the east bounding longitude.', '');
                    bBoxErr = 1;
                } else {
                    if (paramParser.getBBox().southBndLat > paramParser.getBBox().northBndLat) {
                        // failed parsed box paramters - need to generate a default mapBounds & mapExtent
                        //Ext.MessageBox.alert('Error', 'The south bounding latitude cannot be greater than the north bounding latitude.', '');
                        bBoxErr = 1;
                    } else {
                        // acceptable parsed box parameters - need to construct bounding box
                        mapBounds = new OpenLayers.Bounds(bBox[0], bBox[3], bBox[1], bBox[2]);
                        mapExtent = mapBounds.clone();
                        redBox = new OpenLayers.Marker.Box(mapExtent, borderColor);
                        boxes.addMarker(redBox);
                        bBoxErr = 0;
                    }
                }
            }
        }
    }

    if (!(bBoxErr == 0))
    {
        map.layers[1].visibility = false;
    }

    buildUI(urls);

});

// Build the UI
function buildUI(urls){

    // Test URLs
    //urls = new Array('http://domain:8080/path?query_string#fragment_id','http://12.12.23.34:8080/foo', 'http://foobar:8080/foo', 'http:/foobar', 'http//foobar.com', 'http://ogc.bgs.ac.uk/cgi-bin/BGS_1GE_Geology/wms?', 'http://ogc.bgs.ac.uk/cgi-bin/BGS_1GE_Geology/wms', 'http://ogc.bgs.ac.uk/cgi-bin/BGS_1GE_Geology/wms?request=getCapabilities&service=wms', 'http://ogc.bgs.ac.uk/cgi-bin/BGS_1GE_Geology/wms?service=wms&request=getCapabilities&');

    // Check the syntax of the WMS URL.  If it's invalid, remove it from the layer tree.
    // Note:  Valid URLs have the syntax:  scheme://domain:port/path?query_string#fragment_id

    var validUrls = new Array();
    var validUrlsEncoded = new Array();
    var invalidUrls = new Array();
    var validCounter = 0;
    var invalidCounter = 0;

    for (var i = 0; i < urls.length; i++) {
        if (isUrl(urls[i])) {
            // Add URL to validUrls array
            validUrls[validCounter] = urls[i];
            validCounter++;
        } else {
            // Add URL to invalidUrls array
            if (urls[i].length > 0) {
                invalidUrls[invalidCounter] = urls[i];
                invalidCounter++;
            }
        }
    }

    if (invalidUrls.length > 0) {
        var errorStr = "The following WMS URLs have incorrect syntax and will not be displayed in the layer tree: <br><br>";
        for (var i = 0; i < invalidUrls.length; i++) {
            errorStr = errorStr + invalidUrls[i] + "<br>";
        }
        Ext.MessageBox.alert('WMS Error', errorStr, '');
    }

    var childLayerParams = { format: 'image/png', transparent: 'true', version: '1.3.0' };

    // IE browsers handle PNG transparency very badly so gif images are used instead.
    if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)) {
        childLayerParams['format'] = 'image/gif';
    }

    // Build layer tree from valid WMS URLs
    for (var i = 0; i < validUrls.length; i++) {
        // Replace ? and & characters with their HTML encoded counterparts
        var urlWmsSuffix = validUrls[i]; // + wmsSuffix;
        urlWmsSuffix = urlWmsSuffix.replace(/\?/gi, "%3F");
        urlWmsSuffix = urlWmsSuffix.replace(/\&/gi, "%26");
        // Child definition
        child = {
            text: validUrls[i],
            qtip: validUrls[i],
            alive: true,
            loader: new os.WMSCapabilitiesLoader({

                // COI
                url: 'preview_proxy?url=' + urlWmsSuffix,

                // Ordnance Survey
                //url: 'preview_proxy?url=' + urlWmsSuffix,
                layerOptions: {
                    buffer: 0
                    ,singleTile: true
                    ,ratio: 1
                    ,opacity: 0.75
                    ,alpha: true
                    //,gutter: 50
                },
                layerParams: childLayerParams,
                // {
                    // transparent: 'true'
                // },
                createNode: function(attr){
                    attr.qtip = attr.text;
                    attr.checked = attr.leaf ? false : undefined;
                    attr.expanded = attr.leaf ? undefined : true;
                    return os.WMSCapabilitiesLoader.prototype.createNode.apply(this, [attr]);
                },
                listeners: {
                    'load': function(loader, node, response){
                        //console.log("loader has loaded: hasLayers = " + loader.hasLayers);
                        if (!(loader.hasLayers)) {
                            node.attributes.iconCls = 'failedwms-icon';
                            node.getUI().iconNode.className = node.attributes.iconCls;
                        }
                    },
                    'loadexception': function(loader, node, response){
                        //console.log("loader has loaded: hasLayers = " + loader.hasLayers);
                        node.attributes.iconCls = 'failedwms-icon';
                        node.getUI().iconNode.className = node.attributes.iconCls;
                    }
                }
            }),
            expanded: true
        };
        children[i] = child;

    }
//TODO
    var browser = navigator.userAgent;
    if ((browser.toLowerCase().indexOf('safari') > 0) || (/MSIE (\d+\.\d+);/.test(navigator.userAgent))) {
        // set max. length of qtip on child nodes
        for(var i=0; i<children.length; i++) {
            var qtipString = children[i].qtip;
            if (qtipString.length > 50)
            {
                children[i].qtip = qtipString.substring(0,49) + "<br>" + qtipString.substring(50,(qtipString.length));
            }
        }
    }

    // Define the root for the layer tree
    root = new Ext.tree.AsyncTreeNode({
        id: 'root',
        children: children
    });

    // Create checkbox for toggling backdrop map on/off
    checkboxes = new Ext.form.CheckboxGroup({
        id: 'checkboxes'
        ,items: [{
            boxLabel: 'Backdrop Map',
            checked: true,
            handler: function checkvalue(){
                var obj = Ext.select('input[type=checkbox]').elements;
                var i = 0;
                // Toggle backdrop map on/off
                if (obj[i].checked) {
                    baseMappingOn(true);
                    if (map.getZoom() < 9)
                    {
                        baseMappingPreferenceLargeScales = true;
                    }
                }
                else {
                    baseMappingOn(false);
                    if (map.getZoom() < 9)
                    {
                        baseMappingPreferenceLargeScales = false;
                    }
                }
            }
        }]
    });

    // Define the layer tree
    layerTree = new Ext.tree.TreePanel({
        id: 'tree',
        border: false,
        width: 650,
        root: root,
        rootVisible: false,
        animate: true,
        lines: true,
        //autoScroll: true,
        listeners: {
            // Add layers to the map when checked and remove when unchecked
            'checkchange': function(node, checked){
                if (checked === true) {
                    // set layer projection to match map projection
                    switch (mapPanel.map.options.projection)
                    {
                        case "EPSG:4258":
                            node.attributes.layer.get('layer').addOptions(options4258);
                            break;
                        case "EPSG:4326":
                            node.attributes.layer.get('layer').addOptions(options4326);
                            break;
                        case "EPSG:27700":
                            node.attributes.layer.get('layer').addOptions(options27700);
                            break;
                        case "EPSG:29903":
                            node.attributes.layer.get('layer').addOptions(options29903);
                            break;
                        case "EPSG:2157":
                            node.attributes.layer.get('layer').addOptions(options2157);
                            break;
                        default:
                            node.attributes.layer.get('layer').addOptions(options4258);
                    }
                    mapPanel.layers.add(node.attributes.layer);
                    // for testing purposes paramsParsed carries Info/Exception formats defined by testing
                    if (paramsParsed.getInfoFormat() == null) {
                        mapPanel.map.layers[mapPanel.map.getNumLayers() -2].params.INFO_FORMAT = node.attributes.layer.data.INFO_FORMAT;
                    } else {
                        mapPanel.map.layers[mapPanel.map.getNumLayers() -2].params.INFO_FORMAT = paramsParsed.getInfoFormat();
                    }
                    if (paramsParsed.getExceptions() == null) {
                        mapPanel.map.layers[mapPanel.map.getNumLayers() -2].params.EXCEPTIONS = node.attributes.layer.data.EXCEPTIONS;
                    } else {
                        mapPanel.map.layers[mapPanel.map.getNumLayers() -2].params.EXCEPTIONS = paramsParsed.getExceptions();
                    }
                    mapPanel.map.layers[mapPanel.map.getNumLayers() -2].attribution = "";
                    // force redraw (in case projection is not supported and we'd like to see the warning message)
                    mapPanel.map.layers[mapPanel.map.getNumLayers() -2].clearGrid();
                    // redraw is causing some legend titles to be dropped
                    mapPanel.map.layers[mapPanel.map.getNumLayers() -2].redraw(true);
                    // add listener for tileerror event
                    mapPanel.map.layers[mapPanel.map.getNumLayers() -2].events.register("tileerror", this, function(e) {
                        if (e.tile)
                        {
                            if (e.tile.layer.url)
                            {
                                Ext.MessageBox.alert('Error', ("The WMS source: " + e.tile.layer.url + " has failed to load - please switch it off or try a different projection."));
                            }
                        }
                    });
                } else {
                    mapPanel.map.layers[mapPanel.map.getLayerIndex(node.attributes.layer.data.layer)].events.triggerEvent("loadend");
                    mapPanel.layers.remove(node.attributes.layer);
                }
                updateInfoArray();
            },
            'load': function(node){
                // if a node receives a response and no layer child nodes are created we want to change the icon
                // also fires if request is aborted (should this be the case though?)
                if (!(node.isRoot)) {
                    if (node.childNodes) {
                        if (node.childNodes)
                        {
                            if (node.childNodes.length == 0)
                            {
                                node.attributes.iconCls = 'failedwms-icon';
                                node.getUI().iconNode.className = node.attributes.iconCls;
                            }
                        }
                    }
                }
            },
            // loadexception - is this a valid event?
            'loadexception': function(node){
                node.attributes.iconCls = 'failedwms-icon';
                node.getUI().iconNode.className = node.attributes.iconCls;
            }
        }
    });

    // remove key press events for zoomslider - otherwise cursor up/down fire zoom in/out
    GeoExt.ZoomSlider.prototype.onKeyDown = function(e) {};

    // Define the Map panel
    mapPanel = new GeoExt.MapPanel({
        map: map,
        region: 'center',
        items: [{
            xtype: "gx_zoomslider",
            vertical: true,
            // Length of slider
            height: 150,
            // x,y position of slider
            x: 33,
            y: 35,
            // Tooltips
            plugins: new GeoExt.ZoomSliderTip({
                template: "Zoom level: {zoom}<br>Scale: 1 : {scale}"
            })
        }]
    });

    // Define the projection data for the projection combobox
    var projectionData = new Ext.data.SimpleStore({
        id: 0,
        fields: [{
            name: 'projectionName'
        }, {
            name: 'epsg'
        }],
        data: [['ETRS89', '4258'], ['WGS84', '4326'], ['British National Grid', '27700'], ['Irish Grid', '29903'], ['Irish Transverse Mercator', '2157']]
    });

    // define projections
    var proj4258 = new OpenLayers.Projection("EPSG:4258");
    var proj4326 = new OpenLayers.Projection("EPSG:4326");
    var proj27700 = new OpenLayers.Projection("EPSG:27700");
    var proj2157 = new OpenLayers.Projection("EPSG:2157");
    var proj29903 = new OpenLayers.Projection("EPSG:29903");

    // build options for map
    var options4258 = {
        // proper bounds for ETRS89
        maxExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
        restrictedExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
        projection: "EPSG:4258",
        units: "degrees"
    };
    var options4326 = {
        // bounds for WGS84
        maxExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
        restrictedExtent: new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00),
        projection: "EPSG:4326",
        units: "degrees"
    };
    var options27700 = {
        // proper bounds for BNG
        maxExtent: new OpenLayers.Bounds(-1676863.69127, -211235.79185, 810311.58692, 1870908.806),
        restrictedExtent: new OpenLayers.Bounds(-1676863.69127, -211235.79185, 810311.58692, 1870908.806),
        projection: "EPSG:27700",
        units: "m"
    };
    var options2157 = {
        // proper bounds for ITM
        maxExtent: new OpenLayers.Bounds(-1036355.59295, 138271.94508, 1457405.79374, 2105385.88137),
        restrictedExtent: new OpenLayers.Bounds(-1036355.59295, 138271.94508, 1457405.79374, 2105385.88137),
        projection: "EPSG:2157",
        units: "m"
    };
    var options29903 = {
        // proper bounds for IG
        maxExtent: new OpenLayers.Bounds(-1436672.42532, -361887.06768, 1057647.39762, 1605667.48446),
        restrictedExtent: new OpenLayers.Bounds(-1436672.42532, -361887.06768, 1057647.39762, 1605667.48446),
        projection: "EPSG:29903",
        units: "m"
    };

    // Define the form panel for the projection logic
    formPanel = new Ext.form.FormPanel({
        labelWidth: 140,
        border: false,
        items: [{
            xtype: "combo",
            id: 'projectionCombo',
            fieldLabel: "Backdrop Map Projection",
            emptyText: 'Projection',
            store: projectionData,
            displayField: 'projectionName',
            valueField: 'epsg',
            hiddenName: 'theEPSG',
            selectOnFocus: true,
            mode: 'local',
            typeAhead: true,
            editable: false,
            enableKeyEvents: true,
            triggerAction: "all",
            value: '4258',
            listeners: {
                select: function(combo, record, index){
                    var epsg = "EPSG:" + combo.getValue();
                    var centre = mapPanel.map.getCenter().clone();
                    var zoom = mapPanel.map.getZoom();
                    var srcProj = mapPanel.map.getProjectionObject();
                    switch (epsg) {
                        case "EPSG:4258":
                            var baseLayerForEpsg = 'InspireETRS89';
                            var optionsForEpsg = options4258;
                            var projectionForEpsg = proj4258;
                            var layersForEpsg = 'sea_dtm,overview_layers';
                            var transformProjection = true;
                            break;
                        case "EPSG:4326":
                            // WGS84
                            var baseLayerForEpsg = 'InspireWGS84';
                            var optionsForEpsg = options4326;
                            var projectionForEpsg = proj4326;
                            var layersForEpsg = 'sea_dtm_4326,overview_layers';
                            break;

                        case "EPSG:27700":
                            // British National Grid
                            var baseLayerForEpsg = 'InspireBNG';
                            var optionsForEpsg = options27700;
                            var projectionForEpsg = new OpenLayers.Projection("EPSG:27700");
                            var layersForEpsg = 'sea_dtm_27700,overview_layers';
                            var transformProjection = true;
                            break;

                        case "EPSG:2157":
                            // Irish Transverse Mercator
                            var baseLayerForEpsg = 'InspireITM';
                            var optionsForEpsg = options2157;
                            var projectionForEpsg = proj2157;
                            var layersForEpsg = 'sea_dtm_2157,overview_layers';
                            var transformProjection = true;
                            break;

                        case "EPSG:29903":
                            // Irish Grid
                            var baseLayerForEpsg = 'InspireIG';
                            var optionsForEpsg = options29903;
                            var projectionForEpsg = proj29903;
                            var layersForEpsg = 'sea_dtm_29903,overview_layers';
                            var transformProjection = true;
                            break;

                        default:
                            // ETRS89
                            var baseLayerForEpsg = 'InspireETRS89';
                            var optionsForEpsg = options4258;
                            var projectionForEpsg = proj4258;
                            var layersForEpsg = 'sea_dtm_4258,overview_layers';
                            var transformProjection = true;
                            break;
                    }
                    // transform centre
                    centre.transform(srcProj, projectionForEpsg);
                    // set sea raster
                    mapPanel.map.baseLayer.mergeNewParams({ LAYERS: baseLayerForEpsg });
                    // reset map
                    OpenLayers.Util.extend(mapPanel.map, optionsForEpsg);
                    mapPanel.map.options.projection = epsg;
                    // reset layers
                    for (var i = 0, len = mapPanel.map.layers.length; i < len; i++) {
                        mapPanel.map.layers[i].addOptions(optionsForEpsg);
                        if (mapPanel.map.layers[i].name == "Search Criteria") {
                            if (bBoxErr == 0) {
                                if (redBox != null) {
                                    mapExtent = mapBounds.clone();
                                    if (transformProjection) {
                                      mapExtent.transform(proj4326, projectionForEpsg);
                                    }
                                    mapPanel.map.layers[i].removeMarker(redBox);
                                    redBox = new OpenLayers.Marker.Box(mapExtent, borderColor);
                                    mapPanel.map.layers[i].addMarker(redBox);
                                    mapPanel.map.layers[i].redraw();
                                }
                            }
                        }
                    }

                    // overview map
                    // set ov layers
                    overview.ovmap.baseLayer.mergeNewParams({ LAYERS: layersForEpsg });
                    // reset ov map projection details
                    for (var i = 0; i < overview.ovmap.layers.length; i++) {
                        overview.ovmap.layers[i].addOptions(optionsForEpsg);
                    }
                    overview.ovmap.setOptions(optionsForEpsg);
                    overview.ovmap.options.projection = epsg;
                    // centre map
                    mapPanel.map.setCenter(centre, zoom, true, true);
                    mapPanel.map.moveTo(centre);
                    // Openlayers - bug, moveend is not triggered when swapping between etrs89 & wgs84
                    if (srcProj.getCode() == "EPSG:4326" || srcProj.getCode() == "EPSG:4258") {
                        map.events.triggerEvent("moveend");
                    }
                },
                afterrender: function () {
                    this.keyNav.left = function (e) {
                        e.stopPropagation();;
                    }
                    this.keyNav.right= function (e) {
                        e.stopPropagation();
                    }
                },
                specialkey: function(combo, e){
                    if ((e.getKey() == e.LEFT) || (e.getKey() == e.RIGHT) || (e.getKey() == e.UP) || (e.getKey() == e.DOWN)) {
                        e.stopPropagation();
                    }
                }
            }
        }]
    }); // end of formpanel def

    keyboardSelModel = Ext.extend(Ext.tree.DefaultSelectionModel,{
        onKeyDown:function(e){
            // if there is no selected node we can presume that the key press came from outside
            // the activelayerspanel - e.g. the map window, see map.events.moveend
            var selectedNodePresent = false;
            Ext.each(activeLayersPanel.getRootNode().childNodes, function(node)
            {
                if (node.isSelected())
                {
                    selectedNodePresent = true
                }
            });
            if (selectedNodePresent)
            {
                e.stopPropagation();
                keyboardSelModel.superclass.onKeyDown.call(this,e);
                var newValueOfSlider;
                switch (e.getCharCode())
                {
                    case 37:
                        // cursor key LEFT
                        newValueOfSlider = this.selNode.component.getValue() - 5;
                        if (newValueOfSlider < 0) {
                            newValueOfSlider = 0;
                        }
                        this.selNode.component.setValue(newValueOfSlider, true);
                        this.selNode.component.layer.setOpacity(newValueOfSlider/100);
                        break;
                    case 38:
                        // cursor key UP
                        if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
                            this.selectPrevious(this.selNode);
                        }
                        break;
                    case 39:
                        // cursor key RIGHT
                        newValueOfSlider = this.selNode.component.getValue() + 5;
                        if (newValueOfSlider > 100) {
                            newValueOfSlider = 100;
                        }
                        this.selNode.component.setValue(newValueOfSlider, true);
                        this.selNode.component.layer.setOpacity(newValueOfSlider/100);
                        break;
                    case 40:
                        // cursor key DOWN
                        if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
                            this.selectNext(this.selNode);
                        }
                        break;
                    default:
                }
            } else {
                // do nothing... allow e to propagate through to mapPanel (fingers crossed)
            }
        }
    });

    // Define the Active Layers panel
    activeLayersPanel = new Ext.tree.TreePanel({
        region: "east"
        ,title: "<b>Active Layers</b>"
        ,bodyStyle: 'padding:5px'
        ,width: 250
        ,autoScroll: true
        ,enableDD: true
        // apply the tree node component plugin to layer nodes
        ,plugins: [{
            ptype: "gx_treenodecomponent"
        }]
        ,loader: {
            applyLoader: false,
            uiProviders: {
                "custom_ui": ActiveLayerNodeUI
            }
        }
        ,root: {
            nodeType: "gx_layercontainer"
            ,loader: {
                baseAttrs: {
                    uiProvider: ActiveLayerNodeUI //"custom_ui",
                    ,iconCls: 'gx-activelayer-drag-icon'
                },
                createNode: function(attr) {
                    // add an opacity slider to each node created
                    attr.component = {
                        xtype: "gx_opacityslider",
                        layer: attr.layer,
                        width: 200,
                        aggressive: true,
                        plugins: new GeoExt.LayerOpacitySliderTip({
                            template: "Opacity: {opacity}%"})
                    }
                    attr.checked = null;
                    return GeoExt.tree.LayerLoader.prototype.createNode.call(this, attr);
                },
                filter: function (record) {
                    if (record.getLayer().name == "Search Criteria")
                    {
                        return false;
                    }
                    if (record.getLayer().isBaseLayer == true)
                    {
                        return false;
                    }
                    return record.getLayer().getVisibility();
                }
            }
        }
        ,rootVisible: false
        ,lines: false
        ,selModel: new keyboardSelModel()
        ,listeners: {
            'expand': function(tree){
                // sliders need re-sync when panel is expanded
                Ext.each(tree.getRootNode().childNodes, function(node)
                {
                    if (node.component)
                    {
                        node.component.syncThumb();
                    }
                });
            }
        }
    });

    // Define the Legend panel
    var legendPanel = new GeoExt.LegendPanel({
        // Remove OS base layer from the legend
        filter: function(record){
            return !record.get("layer").isBaseLayer;
        },
        autoScroll: true,
        width: 348,
        bodyStyle: 'padding:5px',
        border: false,
        map: this.map,
        defaults: {
            style: 'padding:5px',
            baseParams: {
                //format: 'image/png',
                //LEGEND_OPTIONS: 'forceLabels:on', - geoserver only
                width: 600
            }
        },
        title: '<b>Legend</b>',
        collapsible: true
    });

    // Define the Layers panel, which will contain projection dropdown, backdrop map toggle and the layer tree
    var layersPanel = new Ext.Panel({
        title: '<b>Layers</b>'
        ,border: false
        ,collapsible: true
        ,bodyStyle: 'padding:5px'
        ,autoScroll: true
        ,items: [formPanel, checkboxes, layerTree]
    });

    // Define the Information panel
    infoPanel = new Ext.Panel({
        title: '<b>Information</b>'
        ,id: 'infoPanel'
        ,collapsible: true
        ,width: 358
        ,border: false
        ,bodyStyle: "padding:10px"
        ,autoScroll: true
        ,style: 'font-family: Arial; font-size: 13px'
        ,html: "<a href=\"/location/preview-on-map\" target=\"_blank\" title=\"Open Help Window\">Need help getting started?</a><br><br>"
        +"Please note:<br><br>"
        +"<b>&#149;</b> Where a rotating circle remains in the WMS Layers window, this indicates that the service is still waiting for a response from that publisher's WMS. This is due to their server not being available or to network problems.<br>"
        +"<b>&#149;</b> Backdrop mapping is available at zoom levels up to the scale of 1:10 000. Additional zoom levels without backdrop mapping are provided to enable viewing of large scale data.<br>"
        +"<b>&#149;</b> On selecting a layer, you may need to zoom in or out to see the data as the Publisher's WMS may restrict the scales at which it can be viewed. <br>"
        +"<b>&#149;</b> You may need to pan to view the data if it is outside current window view. <br>"
        +"<b>&#149;</b> Not all map layers support all projections. If a layer does not display then it may be possible for it to display by choosing a different projection.  <br>"
        +"<b>&#149;</b> To view feature information about the data layers being displayed, position the mouse cursor over the point of interest and click the left button once. A pop-up window will be displayed containing information about features within each layer at that point. If no information is returned, this could be due to there being no features at the point of interest, no support for feature information by the publisher's WMS or a format returned by the WMS which is not supported by the Preview on Map tool. <br>"
        +"<b>&#149;</b> All the backdrop mapping displayed in this window is derived from small scale data and is intended to aid evaluation of selected data sets only. It should not be used to assess their positional accuracy. <br>"
        +"<b>&#149;</b> Users of Internet Explorer  and Opera will find the map pan tool doesn't work in the copyright section. This is a known issue with the mapping framework. A fix will be provided in a future release. <br>"
        +'<b>&#149;</b> Further advice and guidance on all of these notes is provided in the <a href="/location/preview-on-map">Preview on Map User Guide</a>.<br>'
    });

    // Create a panel for Layers, Legend and Information
    leftPanel = new Ext.Panel({
        border: false,
        region: 'west',
        width: 348,
        minWidth: 348,
        collapsible: true,
        collapseMode: "mini",
        layout: 'accordion',
        align: 'stretch',
        split:true,
        minWidth: 200,
        maxWidth: 348,
        items: [layersPanel, activeLayersPanel, legendPanel, infoPanel]
    });

    // Define a viewport.  Left panel (Layers, Legend and Information) will be on the left
    // and the map will be on the right
    new Ext.Viewport({
        layout: "fit",
        hideBorders: false,
        border: true,
        items: {
            layout: "border",
            deferredRender: false,
            items: [leftPanel, mapPanel]
        }
    });

    // clear map history
    hist.clear();

    // If no bounding box issues, zoom to the mapBounds
    if (bBoxErr == 0) {
        map.zoomToExtent(mapBounds);
    } else {
        mapBounds = new OpenLayers.Bounds(-30, 48.00, 3.50, 64.00);
        mapExtent = mapBounds.clone();
        map.zoomToExtent(mapBounds);
    }

}

function updateInfoArray(){
    myLayerURLs = [];   // string array
    myLayers = [];      // OpenLayers.Layer.WMS array
    var len = map.layers.length;
    if (len > 2)
    {
        // at least one layer of interest has been added to the map
        // this first layer goes into the clickControl url parameter
        clickControl.url = map.layers[1].url;
        myLayers.push(map.layers[1]);
        myLayerURLs.push(map.layers[1].url);
        // // all other layers of interest go into the clickControl layerUrls parameter
        if (len > 3)
        {
            for (var i = 2; i < (len - 1); i++) {
                myLayerURLs.push(map.layers[i].url);
                myLayers.push(map.layers[i]); //.params.LAYERS);
            }
        }
        // update the control with the new parameters
        clickControl.layerUrls = myLayerURLs;
        clickControl.layers = myLayers;
    } else {
        // update clickControl
        clickControl.url = null;
        clickControl.layerUrls = [];
        clickControl.layers = [];
    }
}

// Place bounding box layer on top
function moveLayerToTop(layer){
    var topPosition = mapPanel.map.getNumLayers() - 1;
    mapPanel.map.setLayerIndex(layer, topPosition);
}

function switchOnAllLayers(){
    for (var i = 1, len = map.layers.length; i < (len - 1); i++) {
        map.layers[i].setVisibility(true);
    }
}

function baseMappingOn(visible){
    if (visible)
    {
        tiled.setOpacity(1.0);
        tiled.attribution = copyrightStatements;
        //baseMappingPreferenceLargeScales = true;
    } else {
        tiled.setOpacity(0.0);
        tiled.attribution = "";
        //baseMappingPreferenceLargeScales = false;
    }
    var atrControl = map.getControlsByClass("OpenLayers.Control.Attribution");
    atrControl[0].updateAttribution();
}

function disabledEventPropagation(event){
   if (event.stopPropagation){
       event.stopPropagation();
   }
   else if(window.event){
      window.event.cancelBubble=true;
   }
}

// Display error message if there is one or more unreachable WMS URLs
function displayUnreachableMsg(unreachableUrls){

    var errorStr;

    if (unreachableUrls.length > 0) {

        if (unreachableUrls.length == 1) {
            errorStr = "The following Web Map Service URL could not be reached:<br><br>";
        }
        else {
            errorStr = "The following " + unreachableUrls.length + " Web Map Services could not be reached:<br><br>";
        }

        for (var i = 0; i < unreachableUrls.length; i++) {
            errorStr = errorStr + unreachableUrls[i] + "<br>";
        }

        if (reachableUrls.length == 0) {
            errorStr = errorStr + "<br>There are no Web Map Services to overlay.  Please try again."
        }

        Ext.MessageBox.alert('WMS Error', errorStr, '');
    }

}

//function to check/uncheck all the child node.
function toggleCheck(node, isCheck){
    if (node) {
        var args = [isCheck];
        node.cascade(function(){
            c = args[0];
            this.ui.toggleCheck(c);
            this.attributes.checked = c;
        }, null, args);
    }
}

// Check if a URL has correct syntax
function isUrl(s){
    var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    return regexp.test(s);
}

function getHostname(str){
    var re = new RegExp('^(?:f|ht)tp(?:s)?\://([^/]+)', 'im');
    return str.match(re)[1].toString();
}

//function to inspect WMS tree - looking for visible single layers
//was used by the info tool to improve layer naming where layer names
//are not returned by getFeatureInfo requests
//now redundant - could be brought back to improve info results
function checkForSingleLayerInWMS(wmsURL){
    var strWMSURL = wmsURL.replace("?","");
    var root = tree.getRootNode();
    var children = root.childNodes;
    var visibleLayers = 0;
    var layerName;
    for (var i = 0; i < children.length; i++) {
        //alert("checking " + children[i].text.replace("?","") + " for " + strWMSURL);
        if (children[i].text.replace("?","") == strWMSURL ) {
            children[i].cascade(function(n){
                var ui = n.getUI();
                if (ui.isChecked())
                {
                    visibleLayers++;
                    layerName = n.text;
                }
            });
        }
    }
    if (visibleLayers == 1)
    {
        // we can be sure this is the layer in question
        return layerName;
    } else {
        return "";
    }
}

function StringtoXML(text){
    if (window.ActiveXObject){
        var doc=new ActiveXObject('Microsoft.XMLDOM');
        doc.async='false';
        doc.loadXML(text);
    } else {
        var parser=new DOMParser();
        var doc=parser.parseFromString(text,'text/xml');
    }
    return doc;
}

function featuresAttributestoHTMLTable(feature){
    var returnedTable = '<table class="popup">';
    var bolFeatureHasAttributes = false;
    for(var prop in feature.attributes) {
        if(feature.attributes.hasOwnProperty(prop))
            returnedTable += "<tr><td>" + prop + "</td><td>" + feature.attributes[prop] + "</td></tr>";
        bolFeatureHasAttributes = true;
    }
    if (!(bolFeatureHasAttributes))
    {
        returnedTable += "<td>Data not supplied</td>";

    }

    returnedTable = returnedTable.replaceAll(">null<",">Data not supplied<");
    returnedTable = returnedTable.replaceAll(">Null<",">Data not supplied<");
    returnedTable = returnedTable.replaceAll("<td></td>","<td>Data not supplied</td>");
    returnedTable += "</table>";
    return returnedTable;
}

// Replaces all instances of the given substring.
String.prototype.replaceAll = function(strTarget, strSubString ){
    var strText = this;
    var intIndexOfMatch = strText.indexOf( strTarget );
    while (intIndexOfMatch != -1){
        strText = strText.replace( strTarget, strSubString )
        intIndexOfMatch = strText.indexOf( strTarget );
    }
    return( strText );
}
