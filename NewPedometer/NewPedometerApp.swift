//
//  NewPedometerApp.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData

@main
struct NewPedometerApp: App {
    let persistenceController = PedometerPersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showAchievement: AchievementNotificationData?
    @State private var hasProcessedInitialPendingData = false
    
    init() {
        let context = persistenceController.container.viewContext
        CoreDataManager.shared.initializeDefaultAchievements(context: context)
        CoreDataManager.shared.initializeUserStats(context: context)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onAppear {
                        if !hasProcessedInitialPendingData {
                            hasProcessedInitialPendingData = true
                            if let pendingData = AppDelegate.pendingAchievementData {
                                showAchievement = pendingData
                                AppDelegate.pendingAchievementData = nil
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AchievementNotificationTapped"))) { notification in
                        if let userInfo = notification.userInfo,
                           let achievementData = NotificationManager.parseNotificationData(from: userInfo) {
                            if showAchievement == nil {
                                showAchievement = achievementData
                            }
                            AppDelegate.pendingAchievementData = nil
                        }
                    }
            }
            .fullScreenCover(item: $showAchievement) { achievementData in
                AchievementNotificationView(data: achievementData)
                    .onDisappear {
                        showAchievement = nil
                    }
            }
        }
    }
}
