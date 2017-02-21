//
//  FeedViewController.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let CELL_ID : String = "StoryCell"
    
    var feedManager : FeedManager!
    var rssFeeds : [RssFeed]!
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
        DispatchQueue.main.async {
            self.storiesTableView.reloadData()
        }
        //TODO: check for settings changes
    }
    
    func refresh(_ refreshControl : UIRefreshControl) {
        
        //Refresh on background thread to allow spinner to animate properly
        DispatchQueue.global().async {
            self.loadFeeds()
        }
    }
    
    func loadFeeds() {
        feedManager.loadFeeds { (feeds, error) in
            if feeds != nil {
                self.rssFeeds = feeds
                self.rssFeeds.forEach(self.addFeedToStories)
                
                DispatchQueue.main.async {
                    
                    //Sort stories by date
                    self.stories = self.stories.sorted(by: {$0.date < $1.date })
                    self.setStoriesFilter()
                    self.storiesTableView.reloadData()
                    
                    if self.refreshControl.isRefreshing == true {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        stories = []
        activeStories = []
        
        
        //Debug feeds
        let a = ["http://rss.cbc.ca/lineup/canada.xml", "http://rss.cbc.ca/lineup/politics.xml", "http://rss.cbc.ca/lineup/health.xml"]
        let userDefaults = UserDefaults()
        userDefaults.set(a, forKey: "feed_urls")
        //userDefaults.removeObject(forKey: "feed_urls")
        
        
        feedManager = FeedManager()
        if feedManager.isEmpty() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
            }
        } else {
            loadFeeds()
        }
        
        //Table view setup
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
        // show all stories, otherwise only show those that have already been loaded
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
    
    private func addFeedToStories(_ feed : RssFeed) {
        
        //get a list of all currently displayed stories urls
        let currentUrls = self.stories.map({ (item) -> String in
            return item.url
        })
        
        //get any stories that dont have a match
        let newStories = feed.items.filter({ (item) -> Bool in
            return !currentUrls.contains(item.link)
        }).map { (item) -> Story in
            
            //Only take first 3 categores, and ensure they are capitalized
            let categories = item.categories.prefix(3)
            let categoryStr = categories.map({ (category) -> String in
                return category.capitalized
            }).joined(separator: " / ")
            
            return Story.init(item.link ?? "", item.title ?? "", item.pubDate, item.description ?? "", feed.title ?? "", categoryStr)
        }
        
        //add new stories to list
        newStories.forEach({ story in
            self.stories.append(story)
        })
    }
}
