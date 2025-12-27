//
//  NewPedometerAppDelegate.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - Pending Navigation Data
    static var pendingAchievementData: AchievementNotificationData?
    
    // MARK: - UIApplicationDelegate
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
        
        Task { @MainActor in
            NotificationManager.shared.updateBadgeCount()
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {

        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Task { @MainActor in
            NotificationManager.shared.updateBadgeCount()
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Task { @MainActor in
                NotificationManager.shared.updateBadgeCount()
            }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let achievementData = NotificationManager.parseNotificationData(from: userInfo) {
            AppDelegate.pendingAchievementData = achievementData
            
            NotificationCenter.default.post(
                name: NSNotification.Name("AchievementNotificationTapped"),
                object: nil,
                userInfo: userInfo
            )
        }
        
        Task { @MainActor in
            NotificationManager.shared.updateBadgeCount()
        }
        
        completionHandler()
    }
}

