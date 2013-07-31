var app = angular.module("comptool", []);

app.controller("CasterToolLiveCtrl", ["$scope", "$timeout", function ($scope, $timeout) {
  $scope.stats = [];
  $scope.events = [];

//  $scope.Math = Math
  $scope.addEvent = function (type, text, ttl) {
    ttl = ttl || 30;
    var event = {
      type: type,
      text: text,
      occursAt: (new Date().getTime() / 1000) + ttl
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

  $scope.addStat = function (name, cls, color, text) {
    var stat = {
      name: name,
      'class': cls,
      color: color,
      text: text
    };
    $scope.stats.push(stat);
    $timeout(function () {
      $scope.stats.shift();
    }, 30 * 1000);
  };

  $timeout(function () {
    $scope.addEvent("player-killed", "Test message here");
  }, 1000);
  $timeout(function () {
    $scope.addEvent("player-killed", "Test message here");
  }, 2000);
  $timeout(function () {
    $scope.addEvent("medic-killed", "Important test message here");
  }, 3500);
  $timeout(function () {
    $scope.addEvent("player-killed", "Test message here");
  }, 8000);
  $timeout(function () {
    $scope.addEvent("player-killed", "Test message here");
  }, 9500);
  $timeout(function () {
    $scope.addEvent("player-killed", "Test message here");
  }, 12000);

  $timeout(function () {
    $scope.addStat("Player 1", "Demo", "BLU", "Some stat here");
  }, 0);
  $timeout(function () {
    $scope.addStat("Player 2", "Medic", "RED", "Some stat here");
  }, 5*1000);
  $timeout(function () {
    $scope.addStat("Player 3", "Pyro", "BLU", "Some stat here");
  }, 10*1000);
  $timeout(function () {
    $scope.addStat("Player 4", "Scout", "RED", "Some stat here");
  }, 15*1000);
}]);
