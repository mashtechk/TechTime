//  techTimeApp.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI
import Firebase
import SwiftyStoreKit
import KeyboardObserving
import Resolver

@main
struct techtimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
           ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @LazyInjected var authenticationService: AuthenticationService
    
    @State private var pageIndex = 0
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
        FirebaseApp.configure()
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        print("----- this is the true -----")
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        // Unlock content
                    case .failed, .purchasing, .deferred:
                        print("----- this is the error in app purchase -----")
                        break // do nothing
                    @unknown default:
                        print("----- this is the default switch case -----")
                        break
                    }
                }
            }
        return true
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Enter ho gya bhaiii....")
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("active")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("kill the application...")
        
    }
    
    func handleNotificationWhenAppIsKilled(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let remoteNotification = launchOptions?[.remoteNotification] as?  [AnyHashable : Any] {
             print("remote notification is \(remoteNotification)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            print("silent is \(userInfo)")
        }
    
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  // A Keyboard that will be added to the environment.
  var keyboard = Keyboard()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

    //Use a UIHostingController as window root view controller
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: ContentView()
          // Adds the keyboard to the environment
//          .environmentObject(keyboard)
      )
      self.window = window
      window.makeKeyAndVisible()
    }
  }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("Activated.....")

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("Enter ho gya bhai......")
    }

}
