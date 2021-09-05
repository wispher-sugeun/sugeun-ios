//
//  SceneDelegate.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        if(UserDefaults.standard.string(forKey: UserDefaultKey.isNewUser) == "1" && UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken) != nil) {
            print("자동 로그인 성공 -> 메인 화면으로 이동")
            //자동 로그인 성공 -> 메인 화면으로 이동
            guard let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC") as? ViewController else {
                print("can not find mainVC")
                return
            }
          
            let rootNC = UINavigationController(rootViewController: mainVC)
            
            print(rootNC)
        
            window!.rootViewController = rootNC
            window!.makeKeyAndVisible()
            
        }else {
            print("jwtToken과 isNewUser 정보가 없어 로그인 뷰로 이동")
            let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
            guard let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login") as? LoginViewController else {
                print("can not find loginNavC")
                return
            }

            let rootNC = UINavigationController(rootViewController: loginVC)
            window!.rootViewController = rootNC
            window!.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

