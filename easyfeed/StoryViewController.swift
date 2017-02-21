//
//  StoryViewController.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController, UIGestureRecognizerDelegate {

    var story : Story!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
                dismiss(animated: true, completion: nil)
        }

        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self

        webView.scrollView.addGestureRecognizer(doubleTapGesture)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTheme()

        let userDefaults = UserDefaults()
        let theme = userDefaults.bool(forKey: "selected_theme") == true ? "dark" : "light"
        let showImages = userDefaults.bool(forKey: "show_images")
        webView.backgroundColor = UIColor.clear
        webView.isHidden = true
        story.loadStory(theme, showImages, completed: {

            //TODO: Get cardcoded html strings for contaning + styling content
            self.webView.loadHTMLString(self.story.contents, baseURL: nil)
            self.webView.isHidden = false
            print("Story Loaded")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTheme()
    }

    private func setTheme() {
        let userDefaults = UserDefaults()

        if userDefaults.bool(forKey: "selected_theme") == true {
            print("set dark theme")
        } else {
            print("set light theme")
        }
    }

}
