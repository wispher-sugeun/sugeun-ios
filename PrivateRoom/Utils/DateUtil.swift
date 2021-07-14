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

        return formatter.date(from: dateString) ?? Date()
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"

        return formatter.string(from: date)
    }
    
    
}
