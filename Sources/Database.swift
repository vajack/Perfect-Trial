//
//  database.swift
//  PerfectTemplate
//
//  Created by IkegamiYuki on 2016/12/15.
//
//

import PerfectLib
import SQLite
import PerfectHTTP
import PerfectMustache
import SwiftString

class DB {
    let dbPath = "./blog-database"
    
    func create() {
        do {
            let sqlite = try SQLite(dbPath)
            defer {
                sqlite.close()
            }
            try sqlite.execute(statement: "CREATE TABLE IF NOT EXISTS blog (id INTEGER PRIMARY KEY NOT NULL, title TEXT NOT NULL, titlesanitized TEXT NOT NULL, synopsis TEXT NOT NULL, body TEXT NOT NULL)")
        } catch {
            print(error)
        }
    }
    
    func populate() {
        let data = [
            ["Title","Sub Title","Test blog text. This text is testing data."]
        ]
        
        do {
            let sqlite = try SQLite(dbPath)
            defer {
                sqlite.close()
            }
            try sqlite.execute(statement: "DELETE FROM blog")
            
            for i in 0..<data.count {
                try sqlite.execute(statement: "INSERT INTO blog (id,title,titlesanitized,synopsis,body) VALUES(:1,:2,:3,:4,:5)", doBindings: {
                    (statement: SQLiteStmt) -> () in
                    try statement.bind(position: 1, (i + 1))
                    try statement.bind(position: 2, data[i][0])
                    try statement.bind(position: 3, data[i][0].slugify())
                    try statement.bind(position: 4, data[i][1])
                    try statement.bind(position: 5, data[i][2])
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getList() -> [[String: String]] {
        var data = [[String: String]]()
        do {
            let sqlite = try SQLite(dbPath)
            defer {
                sqlite.close()
            }
            
            let demoStatement = "SELECT title,synopsis FROM blog"
            
            try sqlite.forEachRow(statement: demoStatement, handleRow: {(statement: SQLiteStmt, i: Int) -> () in
                var contentDict = [String: String]()
                contentDict["title"] = String(statement.columnText(position: 0))
                contentDict["synopsis"] = String(statement.columnText(position: 1))
                data.append(contentDict)
            })
            
        } catch {
            print(error)
        }
        
        return data
    }
    
    func getStory(_ storyid:String) -> [String: String] {
        var data = [String: String]()
        
        do {
            let sqlite = try SQLite(dbPath)
            
            defer {
                sqlite.close()
            }
            
            let demoStatement = "SELECT title,body FROM blog WHERE titlesanitized = :1"
            
            try sqlite.forEachRow(statement: demoStatement, doBindings: {
                (statement: SQLiteStmt) -> () in
                
                try statement.bind(position: 1, storyid)
                
            }, handleRow: { (statement: SQLiteStmt, i:Int) -> () in
                data["title"] = String(statement.columnText(position: 0))
                data["body"] = String(statement.columnText(position: 1))
            })
        } catch {
            print(error)
        }
        return data
    }
}
