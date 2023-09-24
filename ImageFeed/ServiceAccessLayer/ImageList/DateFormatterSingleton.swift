//
//  DateFormatterSingleton.swift
//  ImageFeed
//
//  Created by Dmitry Kirdin on 21.02.2024.
//

import Foundation

final class DateFormatterSingleton {
    static let shared = DateFormatterSingleton()
    let dateFormatterISO8601: AnyObject
    let dateFormatter: AnyObject
    
    init() {
        dateFormatterISO8601 = ISO8601DateFormatter()
        let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .none
        dateFormatter = formater
    }
    
    func date(from stringDate: String) -> Date? {
        return dateFormatterISO8601.date(from: stringDate)
    }
    
    func string(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
