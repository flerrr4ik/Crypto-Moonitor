//
//  SceneDelegate.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 21.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Scene Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

//        let window = UIWindow(windowScene: windowScene)
//        let rootVC = MainListVC()
//        window.rootViewController = UINavigationController(rootViewController: rootVC)
//        self.window = window
//        window.makeKeyAndVisible()
        
        let window = UIWindow(windowScene: windowScene)
        let rootVC = SplashViewController()
        window.rootViewController = rootVC
        self.window = window
        window.makeKeyAndVisible()
    }

    // MARK: - Scene State Transitions
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Clean up any resources when the scene is disconnected
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any paused tasks when the scene becomes active
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks when the scene is about to resign active
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Prepare for foreground transition
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data and release resources when entering background
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
