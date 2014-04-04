"use strict";

var node_xslt = require('node_xslt');

module.exports.parser = parser; 
module.exports.generateApiStub = generateApiStub;

function parser(wadlFileName) {

	var resources = {};
	var wadlToJsonStylesheet = node_xslt.readXsltFile(require('path').resolve(__dirname, 'wadl2json.xsl'));
	var wadlFile = node_xslt.readXmlFile(wadlFileName);
	var wadlDesc = node_xslt.transform(wadlToJsonStylesheet, wadlFile, []);
	
	parse(wadlDesc);

	function addResource (descriptor) {
		var path = resolvePath(descriptor);
		descriptor.methods = descriptor.methods.map(function (m) { m.name = m.name.toLowerCase(); return m; });
		if (descriptor.methods.requests && descriptor.methods.requests.params) {
			descriptor.methods.requests.params = descriptor.methods.requests.params(function (m) { if (m.style === 'header') { m.style.name = m.style.name.toLowerCase(); }return m; });	
		}
		if (descriptor.methods.responses && descriptor.methods.responses.params) {
			descriptor.methods.responses.params = descriptor.methods.responses.params(function (m) { if (m.style === 'header') { m.style.name = m.style.name.toLowerCase(); }return m; });	
		}
		
		resources[path] = descriptor;
	}

	function parse (obj) {
		obj = typeof obj === 'string' ? JSON.parse(obj) : obj;
		obj.resources.forEach(function (resources) {
			resources.resources.forEach(addResource);
		});
	}

	function getRoutes () {
		var routes = [];
		for (var path in resources) {
			var r = resources[path];
			r.methods.forEach(function (method) {
				routes.push({ path: path, desc: method });
			});
		}
		return routes;
	}

	return {
		parse: parse
		,getRoutes: getRoutes
	}
}

function resolvePath (descriptor) {
	var path = descriptor.fullPath.filter(function (p) { return p !== '/'}).map(function (p) { return p.replace(/^\//, '').replace(/\/$/, '') }).join('/');
	path = path.charAt(0) === '/' ? path : '/' + path;
	path = path.replace(/\{([^\}]+)\}/g, ":$1");
	return path;
}

function generateApiStub (routes) {
	var s = '"use strict";\n\n// This is a generated stub file.\n\nmodule.exports.register = function (app) {\n\n';
	routes.forEach(function (route) {
		var path = route.path;
		var method = route.desc.name.toLowerCase();
		if (route.desc.request.params) {
			s += '/**\n * Parameters:\n';
			route.desc.request.params.forEach(function (param) {
				s += ' * ' + param.name + ' (' + param.style + ', ' + (param.required ? 'required' : 'optional' ) + ')\n';
			});
			s += ' **/\n';
		}
		s += 'app.' + method + '("' + path + '", function (req, res, next) {\n\tconsole.log("Implement me!");\n\tnext();\n'
		s += '});\n\n'
	});
	s += '}'
	return s;
}