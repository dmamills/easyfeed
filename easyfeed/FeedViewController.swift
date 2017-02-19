//
//  FeedViewController.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let CELL_ID = "StoryCell"
    var currentFeedUrl : String!
    var rssFeed : RssFeed!
    var stories : [Story]!
    var activeStories : [Story]!
    
    @IBOutlet weak var storiesTableView: UITableView!
    @IBOutlet weak var storyFilterSegementControl: UISegmentedControl!
    
    var refreshControl : UIRefreshControl!
    
    let DARK_BACKGROUND_COLOR = UIColor.fromRGB(52, 52, 61)
    let DARK_FONT_COLOR = UIColor.fromRGB(229, 243, 244)
    let LIGHT_BACKGROUND_COLOR = UIColor.fromRGB(255, 255, 255)
    let LIGHT_FONT_COLOR = UIColor.fromRGB(75, 77, 77)
 
    
    override func viewWillAppear(_ animated: Bool) {
        setTheme()
        
        let userDefaults = UserDefaults()
        if let feedUrl = userDefaults.string(forKey: "feed_url") {
            if feedUrl != currentFeedUrl {
                //load new feed
                loadFeed(feedUrl)
                currentFeedUrl = feedUrl
            } else {
                //Just reset theme
                DispatchQueue.main.async {
                    self.storiesTableView.reloadData()
                }
            }
        }
    }
    
    func loadFeed(_ feedUrl : String) {
        let feedParser = FeedParser(feedUrl)
        feedParser.parse(completed: self.onFeedCompleted)
    }
    
    func refresh(_ refresdhControl : UIRefreshControl) {
        
        //Refresh on background thread to allow spinner to animate properly
        DispatchQueue.global().async {
            self.loadFeed(self.currentFeedUrl)
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        stories = []
        activeStories = []
        setTheme()
        

        let userDefaults = UserDefaults()
        
        //userDefaults.removeObject(forKey: "feed_url")
        //userDefaults.set("https://www.wired.com/feed/", forKey: "feed_url")
        
        if let feedUrl = userDefaults.string(forKey: "feed_url") {
            currentFeedUrl = feedUrl
            if currentFeedUrl.isEmpty {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
                }
                return
                
            } else {
                loadFeed(currentFeedUrl)
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
            }
        }
        
        storiesTableView.delegate = self
        storiesTableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        storiesTableView.refreshControl = refreshControl
        storiesTableView.addSubview(refreshControl)
    }

    @IBAction func onSettingsTouch(_ sender: Any) {
        performSegue(withIdentifier: "showSettingsSegue", sender: self)
    }
    
    @IBAction func onStoryFilterChanged(_ sender: UISegmentedControl) {
        setStoriesFilter()
        DispatchQueue.main.async {
            self.storiesTableView.reloadData()
        }
    }
    
    func setStoriesFilter() {
        if storyFilterSegementControl.selectedSegmentIndex == 0 {
            activeStories = stories
        } else {
            activeStories = stories.filter({$0.contents != nil})
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as? StoryTableViewCell {
        
            let story = activeStories[indexPath.row]
            let theme = UserDefaults().bool(forKey: "selected_theme") == true ? "dark" : "light"
            cell.configureUI(story, theme)
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let story = activeStories[indexPath.row]
        performSegue(withIdentifier: "showStorySegue", sender: story)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showStorySegue" {
            if let vc = segue.destination as? StoryViewController {
                if let story = sender as? Story {
                    vc.story = story
                }
            }
        }
    }
    
    private func mapItems(_ item: FeedItem) -> Story {
        
        //Only take first 3 categores, and ensure they are capitalized
        let categories = item.categories.prefix(3)
        let categoryStr = categories.map({ (category) -> String in
            return category.capitalized
        }).joined(separator: " / ")
        
        return Story.init(item.link ?? "", item.title ?? "", item.pubDate, item.description ?? "", rssFeed.title ?? "", categoryStr)
    }
    
    private func onFeedCompleted(_ feed: RssFeed?, _ error : Error?) {
        
        if error != nil {
            print("error")
        } else if feed != nil {
        
            self.rssFeed = feed
            
            //get all current urls
            let currentUrls = self.stories.map({ (item) -> String in
                return item.url
            })
            
            //get any stories that dont have a match
            let newStories = feed?.items.filter({ (item) -> Bool in
                return !currentUrls.contains(item.link)
            }).map(self.mapItems)
            
            if newStories != nil {
                newStories?.forEach({ story in
                    self.stories.append(story)
                })
                //self.stories.append(newStories)
                self.activeStories = self.stories
            }
            
            setStoriesFilter()
            
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing == true {
                    self.refreshControl.endRefreshing()
                }
                self.storiesTableView.reloadData()
            }
        }
        
    }
    
    private func setTheme() {}

}
