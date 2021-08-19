//
//  PutScheduleRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/19.
//

import Foundation


struct PutScheduleRequest: Codable {
    var scheduleId: Int

    var userId: Int

    var title: String

    var selected: [Int]

    var scheduleDate: String
}
