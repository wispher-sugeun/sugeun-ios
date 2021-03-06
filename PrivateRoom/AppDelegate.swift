//
//  AppDelegate.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/09.
//

import UIKit
import CoreData
import UserNotifications
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //push notification  
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
              print("Permission granted: \(granted)")

          }
        // APNS 등록
        application.registerForRemoteNotifications()

        
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("failed to register for notifications")
       }

   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let tokenParts = deviceToken.map {
           data in String(format: "%02.2hhx", data) }
       let deviceToken = tokenParts.joined()
        //UserDefaults.standard.setValue(deviceToken, forKey: UserDefaultKey.jwtToken)
       print("Device Token: \(deviceToken)")
   }

   //foreground에서 알림이 온 상태
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       // 푸시가 오면 alert, badge, sound표시를 하라는 의미
    completionHandler([.list, .sound, .badge, .banner])
   }
    
    

   //TODO
   //push 온 경우 (보내는 쪽)
   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.identifier)
    //parsing && 화면 분기
    if(response.notification.request.identifier == "authenMessage"){
        //nothing
    
    }else if(response.notification.request.identifier.contains("t_")){ // timeout
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC") as! ViewController
        mainVC.currentIndex = 3
        let rootNC = UINavigationController(rootViewController: mainVC)
        
        UIApplication.shared.windows.first?.rootViewController = rootNC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        //let notiVC = UIStoryboard.init(name: "Timeout", bundle: nil).instantiateViewController(identifier: "noti") as NotiViewController
    }else if(response.notification.request.identifier.contains("s_")){ // schedule
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC") as! ViewController
        mainVC.currentIndex = 3
        let rootNC = UINavigationController(rootViewController: mainVC)
        
        UIApplication.shared.windows.first?.rootViewController = rootNC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        //let calendarVC = UIStoryboard.init(name: "Calendar", bundle: nil).instantiateViewController(identifier: "calendar") as CalendarViewController
    }
    
    print("\(response.notification.request.content)")
    completionHandler()

    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PrivateRoom")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


extension NSNotification.Name {
    static let alarm = NSNotification.Name("alarm")
}
