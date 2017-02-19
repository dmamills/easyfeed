//
//  SettingsManager.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-17.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation

class SettingsManager {
    
    var userSettings : UserDefaults!
    let FEED_KEY = "feed_url"
    let THEME_KEY = "selected_theme"
    let SHOW_IMG_KEY = "show_images"
    
    init() {
        userSettings = UserDefaults()
    }
    
    func getFeed() -> String? {
        return userSettings.string(forKey: FEED_KEY)
    }
}
