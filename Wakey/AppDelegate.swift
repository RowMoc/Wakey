//
//  AppDelegate.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/01.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        configEasyTipsPrefs()
        configClearNavbar()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
//        if #available(iOS 10.0, *) {
//          // For iOS 10 display notification (sent via APNS)
//          UNUserNotificationCenter.current().delegate = self
//
//          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//          UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: {_, _ in })
//        } else {
//          let settings: UIUserNotificationSettings =
//          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//          application.registerUserNotificationSettings(settings)
//        }
        application.registerForRemoteNotifications()

        // [END register_for_notifications]
        return true
        
    }
    
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        // Check for newly received alarms that aren't already part of the set alarm
        //print("BACKGROUND FETCH CALLED")
//        var alarmArray = UserDefaults.standard.array(forKey: constants.scheduledAlarms.scheduledAlarmsArrayKey) as? [(String, Double, Date)] ?? []
//        var alarmsToAdd: [receivedAlarm] = []
//        FirebaseManager.shared.fetchAllAlarmsReceived { (error, alarms) in
//            if alarms.isEmpty || error != nil {
//                //print("BACKGROUND FETCH: no new data")
//                completionHandler(.noData)
//            } else {
//                for alarm in alarms {
//                    if !alarmArray.contains(where: { $0.0 == alarm.audioID }) {
//                        //print("BACKGROUND FETCH: found alarm not yet part of alarm")
//                        alarmsToAdd.append(alarm)
//                    }
//                }
//            }
//        }
//        //Daisy chain the new alarms onto the existing notifications
//        let whenToFire = Calendar.current.date(byAdding: .second, value: 2, to: alarmArray.last?.2 ?? Date())!
//        getAudios(fetchedAlarms: alarmsToAdd, timeToFire: whenToFire) { (error, notifications) in
//            for request in (notifications as! [UNNotificationRequest]) {
//                let info = request.content.userInfo
//                let audioID = info[constants.scheduledAlarms.audioIDKey] as? String ?? ""
//                let alarmLength = info[constants.scheduledAlarms.alarmLengthKey] as? Double ?? 30.0
//                let isFiringWhen = info[constants.scheduledAlarms.whenToFireKey] as? Date ?? Date()
//                UNUserNotificationCenter.current().delegate = self
//                UNUserNotificationCenter.current().add(request) { (error) in
//                    if (error == nil){
//                        //print("ADDED LOCAL NOTIFICATION FROM BACKGROUND FETCH")
//                        alarmArray.append((audioID, alarmLength, isFiringWhen))
//                    }
//                }
//            }
//            completionHandler(.newData)
//            UserDefaults.standard.set(alarmArray, forKey: constants.scheduledAlarms.scheduledAlarmsArrayKey)
//            UserDefaults.standard.synchronize()
//        }
        
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
        let container = NSPersistentContainer(name: "Wakey")
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
    
    func configClearNavbar() {
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
    }

}

extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")
    
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]
}

