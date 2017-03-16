//
//  StoryFileManager.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-03-15.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation

class StoryFileManager {
    
    let fileManager : FileManager
    
    init() {
        fileManager = FileManager.default
    }
    
    func doesExist(_ title : String, _ theme : String) -> Bool {
        let filePath = getPathToStory(title, theme)
        return fileManager.fileExists(atPath: filePath)
    }
    
    func loadStoryFromFile(_ title : String, _ theme : String) -> Story? {
        
        let safeTitle = convertTitleForFile(title)
        let filePath = getPathToStory(safeTitle, theme);
        
        do {
            let contents = try String(contentsOfFile: filePath)
            print("got story")
        } catch {
            print("error loading file.")
        }
        
        return nil
    }
    
    func saveStoryToFile(_ story : Story) {
        
        let safeTitle = convertTitleForFile(story.title ?? "")
        let filePath = getPathToStory(safeTitle, story.themeFetched);
        fileManager.createFile(atPath: filePath, contents: story.toString().data(using: String.Encoding.utf8), attributes: nil)
    }
    
    private func convertTitleForFile(_ title : String) -> String {
        let invalidCharacters = [ "'", "\"", "\\", "/", " ",".", ","]
        var safeTitle = title
        for var c in invalidCharacters {
            safeTitle = safeTitle.replacingOccurrences(of: c, with: "_")
        }
        
        return safeTitle
    }
    
    private func getPathToStory(_ title: String, _ theme : String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(string: path)
        return url!.appendingPathComponent("\(title)-\(theme).txt").absoluteString
    }
}
