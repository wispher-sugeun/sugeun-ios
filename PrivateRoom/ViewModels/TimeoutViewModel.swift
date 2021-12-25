//
//  TimeoutViewModel.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/12/26.
//

import Foundation
import UIKit

class TimeoutViewModel {
    weak var timeoutVC: NotiViewController?
    var timeOut = [GetTimeoutResponse?]()
    var filteredtimeOut = [GetTimeoutResponse?]()
    
    weak var makeNotiFolderView: MakeNotiFolderView?
    
    func getTimeoutInfo(){
        TimeoutService.shared.getTimeout(completion: { [weak self] (response) in
            guard let self = self else {return}
            self.timeOut = response
            self.filteredtimeOut = self.timeOut
            self.timeoutVC?.collectionView.reloadData()
            let notiManager = LocalNotificationManager()
            notiManager.listScheduledNotifications()
        })
    }
    
    func createTimeoutInfo(createTimoutRequest: CreateTimeoutRequest){
        TimeoutService.shared.createTimeout(createTimoutRequest: createTimoutRequest, completion: { (response) in
            let notiManager = LocalNotificationManager()
            let dateComponents = DateComponents(year: self.makeNotiFolderView?.datePicker.date.year, month: self.makeNotiFolderView?.datePicker.date.month, day: self.makeNotiFolderView?.datePicker.date.day, hour: 12, minute: 0, second: 0)
            let notiidentifier = "t_\(response)_"
            notiManager.notifications = [ Notifications(id: notiidentifier + "0", title: (self.makeNotiFolderView?.nameTextField.text!)!, datetime: dateComponents)]
            let intArray = self.alarmIntArray()
            //선택한 날짜에 대해 알림
            for i in intArray {
                let dateComponents =  DateComponents(year: self.makeNotiFolderView?.datePicker.date.year, month: self.makeNotiFolderView?.datePicker.date.month, day: (self.makeNotiFolderView?.datePicker.date.day)! - i, hour: 12, minute: 0, second: 0)
                notiManager.notifications.append(Notifications(id: notiidentifier + "\(i)", title: (self.makeNotiFolderView?.nameTextField.text!)!, datetime: dateComponents))
            }
            notiManager.timeout()
        })
    }
    
    func updateTimeoutInfo(updateTimeout : UpdateTimeoutRequest, timeoutId: Int, image: Data, selectedArray: [Int]){
        TimeoutService.shared.updateTimeoutInfo(timeoutId: timeoutId, timeoutRequest: updateTimeout)
        TimeoutService.shared.updateTimeoutImage(timeoutId: timeoutId, imageFile: image)
        

        
        //TO DO delete that identifier t_id_0
        ////delete first - t_id_0
        let notiManager = LocalNotificationManager()
        let notiidentifier = "t_\(timeoutId)_"
        notiManager.deleteSchedule(notificationId: notiidentifier + "0")
        for i in selectedArray {
            notiManager.deleteSchedule(notificationId: notiidentifier +
               "\(i)")
        }
        
        ////set renew
        
        let dateComponents = DateComponents(year: makeNotiFolderView?.datePicker.date.year, month: makeNotiFolderView!.datePicker.date.month, day: makeNotiFolderView?.datePicker.date.day, hour: 12, minute: 0, second: 0)
        notiManager.notifications = [ Notifications(id: notiidentifier + "0", title: (makeNotiFolderView?.nameTextField.text!)!, datetime: dateComponents)]
        print("create date : \(dateComponents)")
        
        for i in self.alarmIntArray() {
            let dateComponents =  DateComponents(year: makeNotiFolderView?.datePicker.date.year, month: makeNotiFolderView?.datePicker.date.month, day: (makeNotiFolderView?.datePicker.date.day)! - i, hour: 12, minute: 0, second: 0)
            notiManager.notifications.append(Notifications(id: notiidentifier + "\(i)", title: makeNotiFolderView!.nameTextField.text!, datetime: dateComponents))
        }
        notiManager.timeout()
    }
    
    func alarmIntArray() -> [Int] {
        var intArray = [Int]()
        if(makeNotiFolderView!.weekDayButton.isSelected){
            intArray.append(7)
        }
        if(makeNotiFolderView!.threeDayButton.isSelected){
            intArray.append(3)
        }
        if(makeNotiFolderView!.oneDayButton.isSelected){
            intArray.append(1)
        }
        return intArray
    }
    
}
