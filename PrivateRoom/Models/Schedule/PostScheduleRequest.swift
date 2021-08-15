//
//  PostScheduleRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/10.
//

import Foundation

struct PostScheduleRequest: Codable {
    //var scheduleId:Int

    var userId:Int

    var title: String

    var selected: [Int]

    var scheduleDate: String
    
}


