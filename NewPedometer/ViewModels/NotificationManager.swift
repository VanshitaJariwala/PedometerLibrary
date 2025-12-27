//
//  NotificationManager.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import Foundation
import UserNotifications
import CoreData
import UIKit

// MARK: - Achievement Notification Data
public struct AchievementNotificationData: Identifiable {
    let id = UUID()
    let type: AchievementType
    let achievementValue: Double
    let badgeImageName: String
    let titleText: String
    let descriptionText: String
}

// MARK: - NotificationManager
@MainActor
public final class NotificationManager {
    public static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Notification Request Identifier
    private let notificationIdentifierPrefix = "achievement_"
    
    // MARK: - Badge Count Management
    func updateBadgeCount() {
        let center = UNUserNotificationCenter.current()
        
        center.getDeliveredNotifications { deliveredNotifications in
            let deliveredCount = deliveredNotifications.filter { notification in
                notification.request.identifier.hasPrefix(self.notificationIdentifierPrefix)
            }.count
            
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = deliveredCount
                print("📱 Updated badge count: \(deliveredCount) (notifications in notification center)")
            }
        }
    }
    
    // MARK: - Badge Image Mapping
    func getBadgeImageName(for type: AchievementType, value: Double) -> String {
        switch type {
        case .level:
            let level = getLevelFromSteps(Int64(value))
            return "LV_\(level)"
            
        case .dailySteps:
            return getDailyStepsBadgeName(for: Int(value))
            
        case .totalDays:
            return getTotalDaysBadgeName(for: Int(value))
            
        case .totalDistance:
            return getTotalDistanceBadgeName(for: value)
        }
    }
    
    private func getDailyStepsBadgeName(for steps: Int) -> String {
        if let exactMatch = CoreDataManager.dailyStepsAchievements.first(where: { $0.threshold == steps }) {
            return exactMatch.unlockImage
        }
        
        var bestMatch: String? = nil
        for achievement in CoreDataManager.dailyStepsAchievements {
            if steps >= achievement.threshold {
                bestMatch = achievement.unlockImage
            } else {
                break
            }
        }
        
        return bestMatch ?? CoreDataManager.dailyStepsAchievements.last?.unlockImage ?? "badge3kUnlock"
    }
    
    private func getTotalDaysBadgeName(for days: Int) -> String {
        if let exactMatch = CoreDataManager.totalDaysAchievements.first(where: { $0.threshold == days }) {
            return exactMatch.unlockImage
        }
        
        var bestMatch: String? = nil
        for achievement in CoreDataManager.totalDaysAchievements {
            if days >= achievement.threshold {
                bestMatch = achievement.unlockImage
            } else {
                break
            }
        }
        
        return bestMatch ?? CoreDataManager.totalDaysAchievements.last?.unlockImage ?? "days7Unlock"
    }
    
    private func getTotalDistanceBadgeName(for distance: Double) -> String {
        if let exactMatch = CoreDataManager.totalDistanceAchievements.first(where: { abs($0.threshold - distance) < 0.01 }) {
            return exactMatch.unlockImage
        }
        
        var bestMatch: String? = nil
        for achievement in CoreDataManager.totalDistanceAchievements {
            if distance >= achievement.threshold {
                bestMatch = achievement.unlockImage
            } else {
                break
            }
        }
        
        return bestMatch ?? CoreDataManager.totalDistanceAchievements.last?.unlockImage ?? "miles3Unlock"
    }
    
    private func getLevelFromSteps(_ steps: Int64) -> Int {
        return CoreDataManager.calculateLevel(fromTotalSteps: steps)
    }
    
    // MARK: - Notification Content Generation
    func getNotificationTitle(for type: AchievementType) -> String {
        switch type {
        case .level:
            return LocalizedKey.notificationLevelUp.localized()
        case .dailySteps:
            return LocalizedKey.notificationDailyGoal.localized()
        case .totalDays:
            return LocalizedKey.notificationMilestone.localized()
        case .totalDistance:
            return LocalizedKey.notificationDistanceGoal.localized()
        }
    }
    
    func getNotificationBody(for type: AchievementType, title: String, value: Double) -> String {
        switch type {
        case .level:
            return String(format: LocalizedKey.notificationLevelBody.localized(), title)
        case .dailySteps:
            return String(format: LocalizedKey.notificationDailyBody.localized(), formatSteps(Int(value)))
        case .totalDays:
            return String(format: LocalizedKey.notificationDaysBody.localized(), Int(value))
        case .totalDistance:
            return String(format: LocalizedKey.notificationDistanceBody.localized(), value)
        }
    }
    
    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000000 {
            return String(format: "%.1fM", Double(steps) / 1000000.0)
        } else if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
    
    // MARK: - Notification Scheduling
    public func scheduleAchievementNotification(
        type: AchievementType,
        achievementValue: Double,
        title: String,
        description: String
    ) {
        print("📱 Scheduling notification for achievement: \(type.rawValue) - \(title)")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotification(
                    type: type,
                    achievementValue: achievementValue,
                    title: title,
                    description: description
                )
            } else if settings.authorizationStatus == .notDetermined {
                self.requestNotificationPermission { [weak self] granted in
                    if granted {
                        self?.scheduleNotification(
                            type: type,
                            achievementValue: achievementValue,
                            title: title,
                            description: description
                        )
                    } else {
                        print("❌ Notification permission denied by user")
                    }
                }
            } else {
                print("❌ Notification permission not available (status: \(settings.authorizationStatus.rawValue))")
            }
        }
    }
    
    private func scheduleNotification(
        type: AchievementType,
        achievementValue: Double,
        title: String,
        description: String
    ) {
        let badgeImageName = self.getBadgeImageName(for: type, value: achievementValue)
        
        let notificationTitle = self.getNotificationTitle(for: type)
        let notificationBody = self.getNotificationBody(for: type, title: title, value: achievementValue)
        
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = .default
        
        content.userInfo = [
            "achievementType": type.rawValue,
            "achievementValue": achievementValue,
            "badgeImageName": badgeImageName,
            "titleText": title,
            "descriptionText": description
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let identifier = "\(self.notificationIdentifierPrefix)\(type.rawValue)_\(Int(achievementValue))_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Achievement notification scheduled successfully: \(identifier)")
                print("   Title: \(notificationTitle)")
                print("   Body: \(notificationBody)")
                
                self?.updateBadgeCount()
            }
        }
    }
    
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }
    
    // MARK: - Parse Notification Data
    public static func parseNotificationData(from userInfo: [AnyHashable: Any]) -> AchievementNotificationData? {
        guard let typeString = userInfo["achievementType"] as? String,
              let type = AchievementType(rawValue: typeString),
              let achievementValue = userInfo["achievementValue"] as? Double,
              let badgeImageName = userInfo["badgeImageName"] as? String,
              let titleText = userInfo["titleText"] as? String,
              let descriptionText = userInfo["descriptionText"] as? String else {
            return nil
        }
        
        return AchievementNotificationData(
            type: type,
            achievementValue: achievementValue,
            badgeImageName: badgeImageName,
            titleText: titleText,
            descriptionText: descriptionText
        )
    }
}

