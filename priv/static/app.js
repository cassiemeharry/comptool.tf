function LoginCtrl($scope, $http) {
//  $scope.loggedIn = false;
  $http.get('/api/user').success(function (data) {
    console.debug("auth-check succeeded, data = " + JSON.stringify(data))
    $scope.loggedIn = data.loggedIn;
    $scope.steamId = data.steamId;
    $scope.steamInfo = data.steamInfo;
  }).error(function () {
    $scope.loggedIn = false;
  });
}
