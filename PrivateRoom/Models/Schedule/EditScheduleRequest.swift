//
//  EditScheduleRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/10.
//

import Foundation


struct EditScheduleRequest: Codable {
    var scheduleId:Int

    private var userId:Int

    private var title: String

    private var selected: Int

    private var scheduleDate: String
    
}