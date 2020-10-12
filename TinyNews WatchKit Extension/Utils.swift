//
//  Date.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 11/10/2020.
//
import Foundation

extension Date {
    func getElapsedInterval() -> String {

        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())

        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "yr ago" :
                "\(year)" + " " + "yrs ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "mo ago" :
                "\(month)" + " " + "mos ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hr ago" :
                "\(hour)" + " " + "hrs ago"
        } else if let min = interval.minute, min > 0 {
            return min == 1 ? "\(min)" + " " + "min ago" :
                "\(min)" + " " + "mins ago"
        } else {
            return "a moment ago"

        }

    }
}

extension String {
    public func htmlToPlainStr() -> String {
        let data = Data(self.utf8)
        
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString.string
        }
        
        return String(self)
    }
}

