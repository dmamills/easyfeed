//
//  StoryFileManager.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-03-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation
import GRDB

class StoryFileManager {
    
    var dbQueue : DatabaseQueue?
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let databasePath = documentsPath.appendingPathComponent("db.sqlite")
        dbQueue = try! DatabaseQueue(path: databasePath)
        
        createTable()
    }
    
    func loadStories() -> [Story] {
    
        var stories : [Story] = []
        do {
            try dbQueue?.inDatabase({ db in
                let rows = try Row.fetchCursor(db, "SELECT * FROM stories")
                
                while let row = try rows.next() {
                    stories.append(parseRow(row))
                }
            })
        } catch {
            print("error fetching stories")
        }
        
        return stories
    }
    
    private func parseRow(_ row : Row) -> Story {
        let id : Int64 = row.value(named: "id")
        let url : String = row.value(named: "url")
        let title : String = row.value(named: "title")
        let date : Date = row.value(named: "date")
        let description : String = row.value(named: "description")
        let category : String = row.value(named: "category")
        let feedName : String = row.value(named: "feedName")
        let contents : String = row.value(named: "contents")
        let themeFetched : String = row.value(named: "themeFetched")
        
        let story = Story(url, title, date, description, feedName, category)
        
        story.id = id
        story.contents = contents
        story.themeFetched = themeFetched
        
        return story
    }
    
    private func createTable() {
        do {
        try dbQueue?.inDatabase({ db in
            try db.execute(
                "CREATE TABLE IF NOT EXISTS stories (" +
                    "id INTEGER PRIMARY KEY, " +
                    "title TEXT NOT NULL, " +
                    "url TEXT NOT NULL, " +
                    "date DATETIME NOT NULL, " +
                    "description TEXT NOT NULL, " +
                    "category TEXT NOT NULL, " +
                    "feedName TEXT NOT NULL, " +
                    "contents TEXT NOT NULL, " +
                    "themeFetched TEXT NOT NULL" +
                ")")
            })
        } catch {
            print("Create Table Error.")
        }
    }
    
    func remove(_ id : Int64) -> Bool {
        
        do {
            try dbQueue?.inDatabase({ db in

                try db.execute("DELETE FROM stories WHERE id = \(id)")
                print("removed item")
            })
        } catch {
            print("error occured removing.")
            return false
        }
        
        return true
    }
    
    func insertStory(_ story : Story) -> Bool {
        do {
        
            try dbQueue?.inDatabase({ db in
                try db.execute("INSERT INTO stories (title, url, date, description, category, feedName, contents, themeFetched) VALUES (?,?,?,?,?,?,?,?)", arguments: [story.title, story.url, story.date, story.storyDescription, story.category, story.feedName, story.contents, story.themeFetched])
            })
        } catch {
            print("unable to insert.")
            return false
        }
        
        print("inserted!")
        return true;
    }
}
