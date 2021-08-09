//
//  DateUtil.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/14.
//

import Foundation


class DateUtil {
    
    static func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.date(from: dateString)!
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"

        return formatter.string(from: date)
    }
    
    static func toSecond(_ dateString: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateString)
        return date!.timeIntervalSince1970
    }
    
    
}
