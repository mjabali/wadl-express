wadl-express
============

Transform WADL descriptions to live RESTful web APIs.

   * Parses WADL description files into an intermediary JSON format with all (supported) references resolved. 
   * Creates express/connect 'pre-condition middleware' functions for each resource path, i.e. automatically creates a RESTful API with semantics as defined in the WADL file. 
   * Does scaffoling for REST API modules.
   * Almost complete support of the WADL specification (SUBM-wadl-20090881).
  
Check out the example-server: 

`$ node examples/example-server.js examples/data/db-1-application.wadl 1337`

[Web Application Description Language - W3C Member Submission 31 August 2009](http://www.w3.org/Submission/2009/SUBM-wadl-20090831/)
