;(function (root) {
  var module = angular.module('alerts-ng', []);

  var default_type = 'info';

  var typemap = {
    alert: 'danger',
    notice: 'success'
  };

  module.factory('alerts', function () {
    var alerts = app.alerts || (app.alerts = []);

    return {
      alerts: alerts,
      add: function (message, type) {
        alerts.push({type: this.mapType(type), msg: message});
      },
      close: function (index) {
        alerts.splice(index, 1);
      },
      mapType: function (type) {
        return typemap[type] || type || default_type;
      },
      success: function (message) {
        this.add(message, 'success');
      },
      danger: function (message) {
        this.add(message, 'danger');
      },
      info: function (message) {
        this.add(message, 'info');
      },
      warning: function (message) {
        this.add(message, 'warning');
      }
    }
  });

  module.directive('alerts', ['alerts', function (alerts) {
    return {
      restrict: 'A',
      link: function(scope) {
        scope.alerts = alerts;
      },
      template: '<alert ng-repeat="alert in alerts.alerts" type="{{alerts.mapType(alert.type)}}" close="alerts.close($index)">{{alert.msg}}</alert>'
    };
  }]);

})(window);
