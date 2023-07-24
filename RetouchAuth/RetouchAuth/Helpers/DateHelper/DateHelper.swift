//
//  DateFormatterHelper.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 27.01.2021.
//

import UIKit

public final class ADateHelper {
    // MARK: - Properties
    // Shared
    public static let shared = ADateHelper()

    // Calendar
    public var utcCalendar = Calendar.current

    // UTC TimeZone
    public var utcTimeZone = TimeZone(secondsFromGMT: 0)!

    // Formatters
    private var dateFormatter = DateFormatter()

    public var dateStyleFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.timeZone = utcTimeZone
        return dateFormatter
    }

    // MARK: - Init
    init() {
        utcCalendar.timeZone = utcTimeZone
    }
}
