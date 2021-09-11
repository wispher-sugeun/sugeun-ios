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
    
    func autheMessage(authenCode: Int){
        let content      = UNMutableNotificationContent()
        content.title    = "수근수근 인증번호"
        content.subtitle = "인증번호는 \(authenCode)입니다."
        content.sound    = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "authenMessage", content: content, trigger: trigger)
        print("set schedule \(request)")
        UNUserNotificationCenter.current().add(request) { error in

            guard error == nil else { return }

            print("authenMessage = \(authenCode)")
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
    
    func timeout()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.timeoutNotifications()
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
            content.title    = "(일정📝) 기간이 얼마 남지 않았습니다"
            content.subtitle = notification.title
            content.body = "\(notification.datetime.day!)일전 입니다"
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
    
    private func timeoutNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = "(기프티콘🎁) 기간이 얼마 남지 않았습니다"
            content.subtitle = notification.title
            content.body = "유효기간까지 \(notification.datetime.day!) 남았습니다"
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

        print("notificationId \(notificationId) removed")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        listScheduledNotifications()

    }
    
}

