// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
liveSocket.connect()

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import socket from "./socket";
import mapboxAccessToken from './mapboxAccessToken';
import Packet from "./packet";
import randomColor from "./randomColor";
import symbols from "./symbols";

// common to all pages
$(".dropdown").dropdown();

console.log("APRS.me by W5ISP, N0RUA, and VE6LY");

// FIXME: Break this out into a separate .js entrypoint
// that is only served to logged-in users.
if ($('#map').length !== 1) {
  console.warn("No map element, not initializing app..");
} else {

  let data = {
    markersByCallsign: {},
    polylinesByCallsign: {},
    recentCallsigns: [],
    mapZoom: 10
  };

  window.data = data;

  // map stuff here
  const MAX_ZOOM = 20;

  let map = L.map('map', {
    minZoom: 1,
    maxZoom: MAX_ZOOM,
    worldCopyJump: true,
    keyboard: true
  }).setView([mapLatitude,mapLongitude], 12);

  let resizeMap = () => {
    const height = $(window).height();
    const width = $(window).width();

    $('#map').height(height).width(width);
    map.invalidateSize();
  };

  // let heat = L.heatLayer([], {radius: 20, minOpacity: 0.5});

  // setTimeout(() => {
  //   map.addLayer(heat);
  // });

  $(window).on('resize', () => {
    resizeMap();
  }).trigger('resize');

  L.easyButton('<i class="ui large icon location arrow"></i>', function (btn, map) {
    map.locate({
      maxZoom: 10,
      setView: true,
      timeout: 5000,
    });
  }).addTo(map);

  L.easyButton('<i class="ui large icon angle double right"></i>', function (btn, map) {
    $('#map-sidebar').sidebar({
      dimPage: false,
      closable: false,
      onShow: () => {
        // this still isn't right, we need to set the width depending
        // on whether the sidebar is open or closed.
        resizeMap();
      }
    }).sidebar('toggle');

  }).addTo(map);

  L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
    maxZoom: MAX_ZOOM,
    id: 'mapbox.streets',
    accessToken: mapboxAccessToken
  }).addTo(map);

  let markerGroup = L.markerClusterGroup({
    removeOutsideVisibleBounds: true,
    disableClusteringAtZoom: 8
  });

  map.addLayer(markerGroup);

  // END map stuff

  let mapMarkerService = {
    updateOrCreateMarker: (pkt) => {
      let callsign = pkt.getDisplayName();
      let lat = pkt.latitude;
      let lng = pkt.longitude;
      let packetPos = pkt.getLatLng();

      let marker = data.markersByCallsign[callsign];
      let symbol_icon = symbols(pkt.symboltable + pkt.symbolcode);

//      let symbol_class = "";
//      if (symbols.symbols[pkt.symboltable + pkt.symbolcode] && symbols.symbols[pkt.symboltable + pkt.symbolcode].tocall) {
//        symbol_class = symbols.symbols[pkt.symboltable + pkt.symbolcode].tocall
//      } else {
//        console.log("%c Invalid Symbol: " + pkt.symboltable + pkt.symbolcode, "background: #000; color: #fff");
//      }

      if (marker) {
        const oldLatLng = marker.getLatLng();

        if (pkt.isDifferentLocation(oldLatLng)) {
          let newPos = pkt.getLatLng();

          if (!pkt.isObject()) {
            let polyline = data.polylinesByCallsign[callsign];
            if (polyline) {
              polyline.addLatLng(packetPos);
            }
          }

          marker.setLatLng(packetPos);
          // heat.addLatLng(newPos);

        } else {
          //console.log("  -> location same, skipping");
        }
      } else {
        //console.log("[new]");

        let icon = new L.DivIcon({
          html: `
            <div class="aprs-map-symbol-wrapper">
              <div class="aprs-icon-symbol map">${symbol_icon}<span class="aprs-marker-callsign">${callsign}</span></div>
            </div>
          `,
          className: 'aprs-icon-callsign',
          iconSize : L.point(100, 18),
          iconAnchor: L.point(0, 0)
        });

        marker = new L.Marker(packetPos, {icon: icon});
        markerGroup.addLayer(marker);

        data.recentCallsigns.push(callsign);

        if (!pkt.isObject()) {
          let polyline = L.polyline(packetPos, {color: randomColor(), opacity: 0.8, weight: 4, smoothFactor: 1.0}).addTo(map);
        }
      }

      return marker;
    }
  };

  let APRS = {

    init(socket, map, mapMarkerService) {
      var self = this;
      console.log("APRS.init()");

      console.log("connecting socket")
      socket.connect();
      let channel = socket.channel("aprs:messages");
      console.log("opening channel")

      channel.on("*", (event) => {
        console.warn("Uncaught event: ", event);
      });

      // handle incoming APRS packets
      channel.on("aprs:position", (data) => {
        //console.log("aprs:position", data)
        let pkt = new Packet(JSON.parse(data.payload));

        if (pkt.hasPosition()) {
          if (pkt.isLocation() || pkt.isObject()) {
            let call = pkt.getDisplayName();

            let marker = mapMarkerService.updateOrCreateMarker(pkt);
            let symbol_icon = symbols(pkt.symboltable + pkt.symbolcode);

            let popupText = `
              <div class="ui padded grid">
                <div class="two wide column">
                  <span class="aprs-symbol aprs-icon-symbol">${symbol_icon} ${pkt.symboltable + pkt.symbolcode}</span>
                </div>
                <div class="ten wide column">
                  <h3>
                    <b>${call}</b>
                  </h3>
                </div>
                <div class="four wide column">
                  <a href="/call/${call}" target="_blank">Info <i class="ui icon external"></i></a>
                </div>
            `;

            let customOptions = {
              'maxWidth': '300',
              'minWidth': '300',
              'className': 'station-popup'
            };

            if (pkt.comment !== undefined) {
              popupText += `
                <div class="sixteen wide column">
                  <h4 class="ui horizontal divider">Info</h4>
                </div>
                <div class="sixteen wide column">
                  <p>
                    <em>${pkt.comment}</em>
                  </p>
                </div>
              `;
            } else {
              popupText += `
                <div class="sixteen wide column">
                  <h4 class="ui horizontal divider">Info</h4>
                </div>
                <div class="sixteen wide column">
                  <p>
                  </p>
                </div>
              `;
            }

            popupText += `</div>`

            marker.bindPopup(popupText, customOptions);

          } else {
            console.log("Unhandled packet type:", pkt.type);
          }
        }
      });

      console.log("About to join() channel");
      channel.join()
        .receive("ok", (resp) => {
          console.log("Joined aprs:messages, sending map bounds", resp);
          self._sendMapBounds(map, channel);
        }).receive("error", (reason) => {
          console.log("Join failed because:", reason);
        });

      map.on('zoomend', function (e) {
        self._refreshPositions(map, channel);

        let zoom = map.getZoom();

        // if (zoom <= 8) {
        //   setTimeout(() => {
        //     map.addLayer(heat);
        //   });

        //   // map.addLayer(heat);
        //   console.log("showing heatmap");
        // } else {
        //   if (map.hasLayer(heat)) {
        //     map.removeLayer(heat);
        //   }
        //   console.log("hiding heatmap");
        // }

      });

      map.on('dragend', function (e) {
        self._refreshPositions(map, channel);
      });
    },

    _refreshPositions: function (map, channel) {
      this._clearAllStations(map);
      this._sendMapBounds(map, channel);
    },

    _clearAllStations: function (map) {
      this.__clearPolylines(map);

      data.markersByCallsign = {};
      data.recentCallsigns = [];
      markerGroup.clearLayers();
    },

    __clearPolylines: function (map) {
      for (var callsign in data.polylinesByCallsign) {
        let polyline = data.polylinesByCallsign[callsign];
        map.removeLayer(polyline);
      }

      data.polylinesByCallsign = {};
    },


    _sendMapBounds: (map, channel) => {
      let bounds = map.getBounds();
      let zoom = map.getZoom();

      data.mapZoom = zoom;

      console.log("sendMapBounds: bounds:", bounds);
      console.log("sendMapBounds: zoom:", zoom);

      channel.push('map_bounds', {
        ne: bounds._northEast,
        sw: bounds._southWest,
        zoom: zoom,
      });
    },

  }; // APRS

  APRS.init(socket, map, mapMarkerService);
}
