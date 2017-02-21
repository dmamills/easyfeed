//
//  SettingsViewController.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var themeSegementControl: UISegmentedControl!
    @IBOutlet weak var imagesSegementControl: UISegmentedControl!
    @IBOutlet weak var urlErrorLabel: UILabel!
    @IBOutlet weak var feedsTableView: UITableView!
    
    var userDefaults : UserDefaults!
    var feedUrls : [String]!
    
    @IBAction func onRemoveBtn(_ sender: UIButton) {
        
        if let superview = sender.superview {
            if let cell = superview.superview as? SettingsFeedTableViewCell {
                
                let url = cell.urlLabel.text ?? ""
                if let idx = feedUrls.index(of: url) {
                    feedUrls.remove(at: idx)
                    DispatchQueue.main.async {
                        self.feedsTableView.reloadData()
                    }
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedUrls = []
        
        feedsTableView.delegate = self
        feedsTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFeedCell") as? SettingsFeedTableViewCell {
            
            cell.urlLabel.text = feedUrls[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        userDefaults = UserDefaults()
        urlTextField.delegate = self
        urlErrorLabel.text = ""
        
        if let feedUrls = userDefaults.stringArray(forKey: "feed_urls") {
            self.feedUrls = feedUrls
        }
        
        if userDefaults.bool(forKey: "selected_theme") == true {
            self.themeSegementControl.selectedSegmentIndex = 1
        }

        if userDefaults.bool(forKey: "show_images") == false {
            self.imagesSegementControl.selectedSegmentIndex = 1
        }
        
        self.feedsTableView.reloadData()
    }
    @IBAction func onAddPressed(_ sender: Any) {
        
        let feedUrl = urlTextField.text ?? ""
        
        //TODO: validation for adding feed
        if feedUrl.isEmpty {
         urlErrorLabel.text = "Feed URL required"
            print("Feed url not set, validate")
         
         } else if !validateUrl(feedUrl) {
            urlErrorLabel.text = "Invalid Feed URL"
            print("invalid url, validate")
         } else {
            urlErrorLabel.text = ""
            urlTextField.text = ""
            feedUrls.append(feedUrl)
            feedsTableView.reloadData()
        }
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        
        let theme = themeSegementControl.selectedSegmentIndex == 0 ? "light" : "dark"
        let showImages = imagesSegementControl.selectedSegmentIndex == 0
        
        if feedUrls.count == 0 {
            urlErrorLabel.text = "Must have at least one feed"
        } else {
            urlErrorLabel.text = ""
            userDefaults.set((theme == "dark"), forKey: "selected_theme")
            userDefaults.set(feedUrls, forKey: "feed_urls")
            
            print("saving: \(showImages)")
            userDefaults.set(showImages, forKey: "show_images")
        
            dismiss(animated: true, completion: nil)
        }
    }
    
    func validateUrl(_ url : String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }
        
        return false
    }
}
