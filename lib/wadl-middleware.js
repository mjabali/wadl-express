"use strict";

var wadl 			= require('./resource.js');

module.exports.load = load;
module.exports.wadlMiddleware = middle;
module.exports.addRestHandler = addRestHandler;

function load (wadlFile) {
	return wadl.parser(wadlFile);
	var parser = wadl.parser(wadlFile);
	addRestHandler(app, parser.getRoutes())	
}

function addRestHandler (app, routes) {
	routes.forEach(function (route) {
		//console.log('add route', route.path, route.desc.name);
		try {
			app[route.desc.name](route.path, middle(route.desc));
		} catch (error) {

		}
	});
}

function middle (desc) {
	var ps = (desc.request && desc.request.params ? desc.request.params : []);
	var queryParams = ps.filter(function (p) { return p.style === 'query'; }).filter(function (p) { return p.required; });
	var httpParams = ps.filter(function (p) { return p.style === 'header'}).filter(function (p) { return p.required; }).map(function (p) { p.name = p.name.toLowerCase(); return p;});

	return function middleware (req, res, next) {
		//console.log('Middleware matched URL', req.url, req.method);
		if (desc.name.toLowerCase() !== req.method.toLowerCase()) {
			//console.log('Method mismatch');
			res.statusCode = 405;
			return;
		}
		//console.log('Matched HTTP method.');

		var missingQueryParams = queryParams.filter(function (p) { return typeof req.query[p.name] === 'undefined' });
		if (missingQueryParams.length) {
			//console.log('Query parameter missing', missingQueryParams);
			res.statusCode = 400;
			res.end();
			return;
		}
		//console.log('Found required query parameters.');

		var missingHttpParams = httpParams.filter(function (p) { return typeof req.headers[p.name] === 'undefined' });
		httpParams.filter(function (f) { return f.fixed }) 
		if (missingHttpParams.length) {
			//console.log('HTTP header missing', missingHttpParams);
			res.statusCode = 400;
			res.end();
			return;
		}

		//console.log('Found required HTTP headers.');
		//console.log('Ok, pass thru.');
		next();
	}
}