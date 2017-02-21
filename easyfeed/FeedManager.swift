//
//  FeedManager.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-20.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation
import Alamofire

class FeedManager {
    
    typealias FeedsLoaded = ([RssFeed]?, Error?) -> ()
    let FEED_KEY : String = "feed_urls"
    var userDefaults : UserDefaults!
    var feedUrls : [String]!
    var rssFeeds : [RssFeed]!
    
    init() {
        userDefaults = UserDefaults()
        rssFeeds = []
    }
    
    func addFeed(_ url: String) {
        if feedUrls == nil {
            fetchUrls()
        }
        
        feedUrls.append(url)
        persistUrls()
    }
    
    func removeFeed(_ url : String) -> Bool {
        
        if feedUrls == nil {
            fetchUrls()
        }
        
        if let idx = feedUrls.index(of: url) {
            feedUrls.remove(at: idx)
            persistUrls()
            return true
        }
        
        return false
    }
    
    func loadFeeds(completed: @escaping FeedsLoaded) {
        
        //Reset feeds and get latest stored urls
        rssFeeds = []
        fetchUrls()
        
        //store each callback in a DispatchGroup
        let group = DispatchGroup()
        for i in 0...(feedUrls.count - 1) {
            group.enter()
            let parser = FeedParser(feedUrls[i])
            parser.parse(completed: { (feed, error) in
                //leave group when feed appended
                if let feed = feed {
                    self.rssFeeds.append(feed)
                    group.leave()
                } else {
                    print("feed parsing error")
                }
            })
        }
        
        group.notify(queue: .main, execute: {
            completed(self.rssFeeds, nil)
            print("all loaded")
        })
    }
    
    private func persistUrls() {
        userDefaults.set(feedUrls, forKey: FEED_KEY)
    }
    
    private func fetchUrls() {
        
        feedUrls = userDefaults.stringArray(forKey: FEED_KEY)
        
        if feedUrls == nil {
            feedUrls = []
            persistUrls()
        }
    }
}
