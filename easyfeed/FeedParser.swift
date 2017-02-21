
//
//  FeedParser.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-16.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation

class FeedParser : NSObject, XMLParserDelegate {
    
    typealias OnCompleted = (RssFeed?, Error?) -> ()
    
    let url : String
    var xmlParser : XMLParser!
    var currentElement : String!
    var currentElementValue : String!
    var currentFeedItem : FeedItem!
    var rssFeed : RssFeed!
    
    //Nodes to parse
    let NODE_ITEM : String = "item"
    let NODE_TITLE : String = "title"
    let NODE_LINK : String = "link"
    let NODE_BUILD_DATE : String = "lastBuildDate"
    let NODE_COPYRIGHT : String = "copyright"
    let NODE_DESCRIPTION : String = "description"
    let NODE_PUB_DATE : String = "pubDate"
    let NODE_AUTHOR : String = "author"
    let NODE_CATEGORY : String = "category"
    var NODE_URL : String = "url"
    let NODE_IMAGE : String = "image"
    let NODE_GUID : String = "guid"
    let NODE_LANGUAGE : String = "language"
    let NODE_DOCS : String = "docs"
    let NODE_RSS : String = "rss"
    let NODE_WHITESPACE : String = "\n"
    let ATTRIBUTE_VERSION : String = "version"
    
    var parsingFeedInfo : Bool!
    var parsingImageInfo : Bool!
    var onCompleted : OnCompleted!
    
    init(_ url: String) {
        self.url = url
    }
    
    func parse(completed : @escaping OnCompleted) {
        
        self.onCompleted = completed
        parsingFeedInfo = true
        parsingImageInfo = false
        rssFeed = RssFeed()
        
        xmlParser = XMLParser(contentsOf: URL(string: self.url)!)
        xmlParser.delegate = self
        xmlParser.parse()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.onCompleted(rssFeed, nil)
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        parsingFeedInfo = true
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == NODE_IMAGE {
            parsingImageInfo = true
        }
        
        if elementName == NODE_RSS {
            rssFeed.version = attributeDict["version"]
        }

        if elementName == NODE_ITEM {
            if parsingFeedInfo == true {
                parsingFeedInfo = false
                currentFeedItem = FeedItem()
            } else {
                rssFeed.items.append(currentFeedItem)
                currentFeedItem = FeedItem()
            }
        }
        currentElement = elementName
        currentElementValue = ""
    }
    

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        if elementName == NODE_IMAGE {
            parsingImageInfo = false
        }

        if parsingFeedInfo == true {
            
            if parsingImageInfo == true {
                switch currentElement {
                case NODE_TITLE:
                    rssFeed.imageTitle = currentElementValue
                case NODE_LINK:
                    rssFeed.imageLink = currentElementValue
                case NODE_URL:
                    rssFeed.imageUrl = currentElementValue
                default:
                    missingElement(currentElement, currentElementValue)
                }
            } else {
            
                switch currentElement {
                case NODE_TITLE:
                    rssFeed.title = currentElementValue
                case NODE_LINK:
                    rssFeed.link = currentElementValue
                case NODE_DESCRIPTION:
                    rssFeed.description = currentElementValue
                case NODE_BUILD_DATE:
                    rssFeed.lastBuildDate = Date.fromRssDate(currentElementValue)
                case NODE_COPYRIGHT:
                    rssFeed.copyright = currentElementValue
                case NODE_LANGUAGE:
                    rssFeed.language = currentElementValue
                case NODE_DOCS:
                    rssFeed.docs = currentElementValue
                default:
                    missingElement(currentElement, currentElementValue)
                }
            }
        } else {
            
            switch currentElement {
            case NODE_TITLE:
                currentFeedItem.title = currentElementValue
            case NODE_LINK:
                currentFeedItem.link = currentElementValue
            case NODE_PUB_DATE:
                currentFeedItem.pubDate = Date.fromRssDate(currentElementValue)
            case NODE_DESCRIPTION:
                currentFeedItem.description = currentElementValue
            case NODE_AUTHOR:
                currentFeedItem.author = currentElementValue
            case NODE_CATEGORY:
                currentFeedItem.categories.append(currentElementValue)
            case NODE_GUID:
                currentFeedItem.guid = currentElementValue
            default:
                missingElement(currentElement, currentElementValue)
            }
        }
    }
    
    func missingElement(_ elementName : String, _ value : String) {
        print("Could not parse [element]: \(elementName) [Value]: \(value)")
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.onCompleted(nil, parseError)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //update current value
        if(!(string.trimmingCharacters(in: [" "]) == NODE_WHITESPACE)) {
            currentElementValue = (currentElementValue ?? "") + string
        }
    }
}
