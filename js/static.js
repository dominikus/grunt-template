(function() {
  var cli, middleware;

  cli = require('cli');

  cli.enable('daemon', 'status').setUsage('static.coffee [OPTIONS]');

  cli.parse({
    log: ['l', 'Enable logging'],
    port: ['p', 'Listen on this port', 'number', 8080],
    serve: [false, 'Serve static files from PATH', 'path', './public']
  });

  middleware = [];

  cli.main(function(args, options) {
    var server;
    if (options.log) {
      this.debug('Enabling logging');
      middleware.push(require('creationix/log')());
    }
    this.debug('Serving files from ' + options.serve);
    middleware.push(require('creationix/static')('/', options.serve, 'index.html'));
    server = this.createServer(middleware).listen(options.port);
    return this.ok('Listening on port ' + options.port);
  });

}).call(this);
