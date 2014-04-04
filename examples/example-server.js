"use strict";

var wadlFile = process.argv[2];
var port = parseInt(process.argv[3]);
if (!wadlFile || !port) { console.error('Usage: node example-server.js wadl-file port.'); process.exit(0); }

var wadl 	= require('../index.js').wadl;

var express = require('express');
var app = express();

// 1) Load and parse the WADL file. 
var wadlDescriptor = wadl.load(wadlFile);

// 2) Add the pre-condition handler middleware.
wadl.addRestHandler(app, wadlDescriptor.getRoutes());

// 3) Add "real" middleware
// 
// Create it manually:
//
// app.post('/xyz', function (req, res, next) {
// 	res.end('POST /xyz');
// });
// app.get('/xyz', function (req, res, next) {
// 	res.end('GET /xyz');
// });

// Or load an API module:
// 
// var restApi = require('./generated.js');
// restApi.register(app);

var server = app.listen(1338);