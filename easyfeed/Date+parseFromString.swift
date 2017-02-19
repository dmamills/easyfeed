//
//  Date+parseFromString.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-16.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation

extension Date {

    static func fromRssDate(_ dateStr : String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: dateStr)!
    }
}
