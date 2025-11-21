//
//  DateLabel.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import Foundation

func dateLabel(for date: Date) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
        return "Today"
    } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
    }
    
    // Check if within last 7 days
    if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
        let weekday = calendar.component(.weekday, from: date)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // else show a date
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy"
    return formatter.string(from: date)
}
