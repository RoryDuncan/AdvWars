
var http = require("http");
var router = require("./router");

var port;


function start() {

  http.createServer( router.route ).listen(port || 3030);

  console.log("Server has started on port " + (port || 3030));
}

exports.start = start;