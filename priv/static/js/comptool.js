var app = angular.module("comptool", []);

app.factory("EventStream", ["$q", "$rootScope", "$timeout", function ($q, $rootScope, $timeout) {
  var EventStream = {};

  var callbacks = [];
  var ws = null;
  var ip = null;

  EventStream._setupWS = function () {
    var self = this;
    if (ip === null) {
      console.warn("Can't start websocket connection without TF2 server IP");
      return;
    }
    if (ws instanceof WebSocket) {
      ws.close();
      return;
    }
    var location = "ws://" + document.domain + ":2667/events/"
    console.log("creating websocket connection to " + location);
    ws = new WebSocket(location, "chat");

    ws.onclose = function () {
      ws = null;
      self._setupWS();
    };
    ws.onopen = function () {
      ws.send(ip);
    };

    ws.onmessage = function (event) {
      $rootScope.$apply(function () {
        callbacks.forEach(function (cb) {
          cb(JSON.parse(event.data));
        });
      });
    };
  }

  EventStream.addListener = function (callback) {
    callbacks.push(callback);
  };

  EventStream.setTF2ServerIP = function (serverIP) {
    ip = serverIP;
    this._setupWS();
  }

  return EventStream;
}]);

app.controller("CasterToolLiveCtrl", ["$scope", "$timeout", "EventStream", function ($scope, $timeout, EventStream) {
  $scope.stats = [];
  $scope.events = [];

  $scope.addEvent = function (type, text) {
    var event = {
      type: type,
      text: text,
      occursAt: (new Date().getTime() / 1000) + 30
    };
    var countdown = function () {
      event.ttl = event.occursAt - (new Date().getTime() / 1000);
      if (event.ttl < 0) {
        $scope.events.shift();
      } else {
        $timeout(countdown, 200);
      };
    };
    $scope.events.push(event);
    countdown();
  };

  EventStream.addListener(function (message) {
    $scope.addEvent(message.event_type, message.data.attacker + " killed " + message.data.victim);
  });

  $scope.addStat = function (stat) {
    $scope.stats.push(stat);
    $timeout(function () {
      $scope.stats.shift();
    }, 30 * 1000);
  };

  EventStream.setTF2ServerIP("127.0.0.1");
}]);
