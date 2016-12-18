//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

// Create HTTP server.
let server = HTTPServer()

server.documentRoot = "./webroot"

// Register your own routes and handlers
var routes = Routes()

var dbHandler = DB()
dbHandler.create()
dbHandler.populate()

routes.add(method: .get, uri: "/", handler: {
    request, response in
    
    response.setHeader(.contentType, value: "text/html")
    mustacheRequest(
        request: request,
        response: response,
        handler: ListHandler(),
        templatePath: request.documentRoot + "/index.mustache")
    
    response.completed()
})

routes.add(method: .get, uris: ["/story","/story/{titlesanitized}"], handler: {
    reqest, response in
    
    let titleSanitized = reqest.urlVariables["titlesanitized"] ?? ""
    
    response.setHeader(.contentType, value: "text/html")
    
    if titleSanitized.characters.count > 0 {
        mustacheRequest(
            request: reqest,
            response: response,
            handler: StoryHandler(),
            templatePath: reqest.documentRoot + "/story.mustache" )
    }else{
        
    }
    
    response.completed()
})

// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8181
server.serverPort = 8181

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
