//
//  Story.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-16.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation
import Alamofire


class Story {
    
    typealias DownloadComplete = () -> ()
    
    //let BASE_URL = "http://localhost:9000/story?url="
    //let BASE_URL = "http://yomills.com:9000/story?url="
    let BASE_URL = "http://192.168.1.2:9000/story?url="
    
    var url : String!
    var title : String!
    var date : Date!
    var description : String!
    var category : String!
    var feedName : String!
    var contents : String!
    var themeFetched : String!
    
    init(_ url: String, _ title : String, _ date : Date, _ description : String, _ feedName : String, _ category : String) {
        self.url = url
        self.title = title
        self.date = date
        self.description = description
        self.category = category
        self.feedName = feedName
    }
    
    func loadStory(_ theme: String, _ showImages : Bool, completed: @escaping DownloadComplete) {
        
        if contents != nil && theme == themeFetched {
            print("already fetched.")
            completed()
        } else {
            
            var storyUrl = "\(BASE_URL)\(url!)&theme=\(theme)"
            
            if showImages == true {
                storyUrl += "&img=true"
            }
            
            Alamofire.request(storyUrl).responseString { response in
               // print("Response String: \(response.result.value)")
                self.contents = response.result.value
                self.themeFetched = theme
                completed()
            }
        }
    }
}
