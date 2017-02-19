//
//  SettingsViewController.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var themeSegementControl: UISegmentedControl!
    @IBOutlet weak var imagesSegementControl: UISegmentedControl!
    @IBOutlet weak var urlErrorLabel: UILabel!
    
    var userDefaults : UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        userDefaults = UserDefaults()
        urlTextField.delegate = self
        urlErrorLabel.text = ""
        
        if let feedUrl = userDefaults.string(forKey: "feed_url") {
            urlTextField.text = feedUrl
        }
        
        if userDefaults.bool(forKey: "selected_theme") == true {
            self.themeSegementControl.selectedSegmentIndex = 1
        }

        if userDefaults.bool(forKey: "show_images") == false {
            self.imagesSegementControl.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        
        let feedUrl = urlTextField.text ?? ""
        
        let theme = themeSegementControl.selectedSegmentIndex == 0 ? "light" : "dark"
        let showImages = imagesSegementControl.selectedSegmentIndex == 0
        
        if feedUrl.isEmpty {
            urlErrorLabel.text = "Feed URL required"
            print("Feed url not set, validate")
            
        } else if !validateUrl(feedUrl) {
            urlErrorLabel.text = "Invalid Feed URL"
            print("invalid url, validate")
        } else {
            urlErrorLabel.text = ""
            userDefaults.set(feedUrl, forKey: "feed_url")
            userDefaults.set((theme == "dark"), forKey: "selected_theme")
            
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
