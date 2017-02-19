//
//  RssFeed.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-16.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation

class RssFeed {
    
    var version : String?
    var title : String?
    var link : String?
    var description : String?
    var lastBuildDate : Date?
    var copyright : String?
    var imageTitle : String?
    var imageUrl : String?
    var imageLink : String?
    var docs : String?
    var language : String?
    
    var items : [FeedItem]! = []
}
