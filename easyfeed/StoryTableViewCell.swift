//
//  StoryTableViewCell.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-16.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    let DARK_BACKGROUND_COLOR = UIColor.fromRGB(52, 52, 61)
    let DARK_FONT_COLOR = UIColor.fromRGB(229, 243, 244)
    let LIGHT_BACKGROUND_COLOR = UIColor.fromRGB(255, 255, 255)
    let LIGHT_FONT_COLOR = UIColor.fromRGB(75, 77, 77)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var feedNameLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    
    var currentTheme : String!
    var showImages: Bool!
    var story : Story!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onDownloadPressed(_ sender: Any) {
        if story.contents != nil {
            self.story.contents = nil
            self.downloadBtn.setImage(UIImage(named:"star-unselected"), for: UIControlState.normal)
            print("clear from saved")
        } else {
            print("download story")
            story.loadStory(currentTheme, showImages, completed: {
                DispatchQueue.main.async {
                    self.downloadBtn.setImage(UIImage(named:"star-selected"), for: UIControlState.normal)
                }
            })
        }
    }
    
    func configureUI(_ story: Story, _ theme : String) {
        
        let userDefaults = UserDefaults()
        self.story = story
        self.currentTheme = theme
        self.showImages = userDefaults.bool(forKey: "show_images")
        setTheme()

        self.titleLabel.text = self.story.title
        self.dateLabel.text = formatDate(self.story.date)
        self.feedNameLabel.text = self.story.feedName
        self.categoriesLabel.text = self.story.category
        
        //TODO: switch to story.isSaved?
        if (self.story.contents) != nil {
            self.downloadBtn.setImage(UIImage(named:"star-selected"), for: UIControlState.normal)
        } else {
            self.downloadBtn.setImage(UIImage(named: "star-unselected"), for: UIControlState.normal)
        }
        
        if(showImages == true) {
            self.downloadBtn.isHidden = false
        } else {
            self.downloadBtn.isHidden = true
        }
    }
    
    func setTheme() {
        if currentTheme == "dark" {
            self.titleLabel.textColor = DARK_FONT_COLOR
            self.dateLabel.textColor = DARK_FONT_COLOR
            self.feedNameLabel.textColor = DARK_FONT_COLOR
            self.categoriesLabel.textColor = DARK_FONT_COLOR
            self.backgroundColor = DARK_BACKGROUND_COLOR
        } else {
            self.titleLabel.textColor = LIGHT_FONT_COLOR
            self.dateLabel.textColor = LIGHT_FONT_COLOR
            self.categoriesLabel.textColor = LIGHT_FONT_COLOR
            self.feedNameLabel.textColor = LIGHT_FONT_COLOR
            self.backgroundColor = LIGHT_BACKGROUND_COLOR
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        
        return formatter.string(from: date)
    }
}
