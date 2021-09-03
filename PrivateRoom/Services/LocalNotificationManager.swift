//
//  LocalNotificationManager.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/09/03.
//

import Foundation
import UserNotifications

struct Notifications {
    var id: String
    var title: String
    var datetime: DateComponents
}


class LocalNotificationManager {
    var notifications = [Notifications]()
    
    //현재 스케줄 된 noti 보기
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }
    
    //권한 check
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    
    
    func deleteSchedule(notificationId: String){
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.deleteNotificaion(notificationId: notificationId)
            default:
                break // Do nothing
            }
        }
    }
    
    
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.sound    = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            print("set schedule \(request)")
            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
            
        }
    }
    
    private func deleteNotificaion(notificationId: String){
        print("here")
//        for notification in notifications
//        {
//            if(notification.id == notificationId){
                print("notificationId \(notificationId) removed")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
                listScheduledNotifications()
//            }
//        }
    }
    
    
    
    
    
}

