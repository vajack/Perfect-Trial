//
//  Handlers.swift
//  PerfectTemplate
//
//  Created by IkegamiYuki on 2016/12/15.
//
//

import PerfectLib
import PerfectHTTP
import PerfectMustache
import SQLite


struct ListHandler: MustachePageHandler{
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        var values = MustacheEvaluationContext.MapType()
        var ary = [Any]()
        
        let dbHandler = DB()
        let data = dbHandler.getList()
        
        for i in 0..<data.count {
            var thisPost = [String: String]()
            thisPost["title"] = data[i]["title"]
            thisPost["synopsis"] = data[i]["synopsis"]
            thisPost["titlesanitized"] = data[i]["title"]!.slugify()
            ary.append(thisPost)
        }
        values["posts"] = ary
        
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch  {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
}


struct StoryHandler:MustachePageHandler {
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        
        var values = MustacheEvaluationContext.MapType()
        let reqest = contxt.webRequest
        let titleSanitized = reqest.urlVariables["titlesanitized"] ?? ""
        
        let dbHandler = DB()
        let data = dbHandler.getStory(titleSanitized)
        
        if data["title"] == nil {
            values["title"] = "Error"
            values["body"] = "<p>No story found</p>"
        }else{
            values["title"] = data["title"]
            values["body"] = data["body"]
        }
        
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch  {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
}
