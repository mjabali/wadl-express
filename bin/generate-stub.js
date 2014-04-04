"use strict";

var wadlMiddleware 	= require('../lib/wadl-middleware.js');
var wadl 		= require('../lib/resource.js');

var wadlFile = process.argv[2];
if(!wadlFile) { console.error('Usage: node generate-stub.js wadlfile'); process.exit(0); }

var parser = wadl.parser(wadlFile);

console.log(wadl.generateApiStub(parser.getRoutes()));