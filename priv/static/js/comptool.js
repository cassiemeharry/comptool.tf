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

  var randomEvent = function () {
    var type, text;
    if (Math.random() < 0.1) {
      type = "medic-killed";
      text = "Important test message here";
    } else {
      type = "player-killed";
      text = "Test message here";
    }
    $scope.addEvent(type, text);
    $timeout(randomEvent, ((Math.random() * 10)+0.5)*1000);
  };
  $timeout(randomEvent);

  var randomChoice = function (array) {
    var l = array.length;
    return array[Math.floor(Math.random() * l)];
  };
  var randomStat = function () {
    var player = "Player " + randomChoice([1, 2, 3, 4, 5, 6]);
    var cls = randomChoice(["Scout", "Soldier", "Pyro", "Demo", "Heavy", "Engineer", "Medic", "Sniper", "Spy"]);
    var team = randomChoice(["RED", "BLU"]);
    $scope.addStat(player, cls, team, "Some stat here...");
    $timeout(randomStat, 30 * 1000);
  };
  $timeout(randomStat);

}]);
