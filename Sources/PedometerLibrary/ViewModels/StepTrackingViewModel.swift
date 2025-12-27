//
//  StepTrackingViewModel.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import Foundation
import CoreData
import Combine

// MARK: - StepTrackingViewModel
@MainActor
public final class StepTrackingViewModel: ObservableObject {
    
    // MARK: - Published Properties (Display)
    
    @Published var todaySteps: Int64 = 0
    
    @Published var totalSteps: Int64 = 0
    
    @Published var totalDistance: Double = 0.0
    
    @Published var totalDays: Int32 = 0
    
    @Published var currentLevel: Int32 = 1
    
    @Published var highestDailySteps: Int64 = 0
    
    @Published var isLoading: Bool = false
    
    @Published var errorMessage: String?
    
    @Published var successMessage: String?
    
    // MARK: - Level Progress Properties
    @Published var stepsToNextLevel: Int = 0
    
    @Published var levelProgress: Double = 0.0
    
    @Published var nextLevel: Int = 2
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Initialization
    public init(context: NSManagedObjectContext) {
        self.context = context
        loadUserStats()
        loadTodaySteps()
    }
    
    // MARK: - ADD-ONLY Input Function
    public func addUserInput(
        dailySteps: Int?,
        extraSteps: Int?,
        extraDistance: Double?,
        extraDays: Int?
    ) {
        let hasValidInput = isValidPositive(dailySteps) ||
                           isValidPositive(extraSteps) ||
                           isValidPositive(extraDistance) ||
                           isValidPositive(extraDays)
        
        guard hasValidInput else {
            errorMessage = LocalizedKey.enterPositiveValue.localized()
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let userStats = self.coreDataManager.fetchOrCreateUserStats(context: self.context)
            
            var checkDailySteps = false
            var checkTotalSteps = false
            var checkTotalDistance = false
            var checkTotalDays = false
            
            var todayTotalSteps: Int64 = 0
            
            if let steps = dailySteps, self.isValidPositive(steps) {
                let stepsToAdd = Int64(steps)
                
                if let existingRecord = self.coreDataManager.fetchStepRecord(for: Date(), context: self.context) {
                    existingRecord.steps += stepsToAdd
                    todayTotalSteps = existingRecord.steps
                } else {
                    let newRecord = self.coreDataManager.createOrUpdateStepRecord(
                        date: Date(),
                        steps: stepsToAdd,
                        distance: 0,
                        context: self.context
                    )
                    todayTotalSteps = newRecord.steps
                }
                
                if todayTotalSteps > userStats.highestDailySteps {
                    userStats.highestDailySteps = todayTotalSteps
                }
                
                checkDailySteps = true
            }
            
            if let steps = extraSteps, self.isValidPositive(steps) {
                userStats.totalSteps += Int64(steps)
                checkTotalSteps = true
            }
            
            if let distance = extraDistance, self.isValidPositive(distance) {
                userStats.totalDistance += distance
                checkTotalDistance = true
            }
            
            if let days = extraDays, self.isValidPositive(days) {
                userStats.totalDays += Int32(days)
                checkTotalDays = true
            }
            
            let newLevel = CoreDataManager.calculateLevel(fromTotalSteps: userStats.totalSteps)
            userStats.currentLevel = Int32(newLevel)
            
            userStats.lastUpdated = Date()
            
            self.coreDataManager.saveContext(self.context)
            
            if checkDailySteps {
                self.checkDailyStepsAchievements(dailySteps: todayTotalSteps)
            }
            if checkTotalSteps {
                self.checkLevelAchievements(totalSteps: userStats.totalSteps)
            }
            if checkTotalDistance {
                self.checkTotalDistanceAchievements(totalDistance: userStats.totalDistance)
            }
            if checkTotalDays {
                self.checkTotalDaysAchievements(totalDays: userStats.totalDays)
            }
            
            DispatchQueue.main.async {
                self.todaySteps = todayTotalSteps > 0 ? todayTotalSteps : self.todaySteps
                self.totalSteps = userStats.totalSteps
                self.totalDistance = userStats.totalDistance
                self.totalDays = userStats.totalDays
                self.currentLevel = userStats.currentLevel
                self.highestDailySteps = userStats.highestDailySteps
                self.updateLevelProgress()
                self.isLoading = false
                self.successMessage = LocalizedKey.progressAdded.localized()
            }
        }
    }
    
    // MARK: - Validation Helpers
    private func isValidPositive(_ value: Int?) -> Bool {
        guard let val = value else { return false }
        return val > 0
    }
    
    private func isValidPositive(_ value: Double?) -> Bool {
        guard let val = value else { return false }
        return val > 0
    }
    
    // MARK: - Data Loading
    
    public func loadUserStats() {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let userStats = self.coreDataManager.fetchOrCreateUserStats(context: self.context)
            
            DispatchQueue.main.async {
                self.totalSteps = userStats.totalSteps
                self.totalDistance = userStats.totalDistance
                self.totalDays = userStats.totalDays
                self.currentLevel = userStats.currentLevel
                self.highestDailySteps = userStats.highestDailySteps
                self.updateLevelProgress()
            }
        }
    }
    
    public func loadTodaySteps() {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            if let todayRecord = self.coreDataManager.fetchStepRecord(for: Date(), context: self.context) {
                let todayStepsValue = todayRecord.steps
                
                DispatchQueue.main.async {
                    self.todaySteps = todayStepsValue
                    self.checkDailyStepsAchievements(dailySteps: todayStepsValue)
                }
            }
        }
    }
    
    public func refresh() {
        loadUserStats()
        loadTodaySteps()
    }
    
    // MARK: - Achievement Checking
    private func postAchievementNotification(
        type: AchievementType,
        achievementValue: Double,
        title: String,
        description: String
    ) {
        print("📢 Posting achievement notification: \(type.rawValue) - \(title) (\(achievementValue))")
        Task { @MainActor in
            NotificationManager.shared.scheduleAchievementNotification(
                type: type,
                achievementValue: achievementValue,
                title: title,
                description: description
            )
        }
    }
    
    private func checkDailyStepsAchievements(dailySteps: Int64) {
        print("🔍 Checking daily steps achievements for \(dailySteps) steps")
        context.perform { [weak self] in
            guard let self = self else { return }
            
            var newlyUnlockedAchievements: [(type: AchievementType, value: Double, title: String, description: String)] = []
            
            for achievement in CoreDataManager.dailyStepsAchievements {
                if dailySteps >= achievement.threshold {
                    let wasUnlocked = self.coreDataManager.isAchievementUnlocked(
                        type: "daily_steps",
                        targetValue: Double(achievement.threshold),
                        context: self.context
                    )
                    
                    self.coreDataManager.unlockAchievement(
                        type: "daily_steps",
                        targetValue: Double(achievement.threshold),
                        context: self.context
                    )
                    
                    if !wasUnlocked {
                        print("🎉 New daily steps achievement unlocked: \(achievement.title) (\(achievement.threshold) steps)")
                        newlyUnlockedAchievements.append((
                            type: .dailySteps,
                            value: Double(achievement.threshold),
                            title: achievement.title,
                            description: String(format: LocalizedKey.completedStepsToday.localized(), self.formatSteps(achievement.threshold))
                        ))
                    } else {
                        print("ℹ️ Daily steps achievement already unlocked: \(achievement.title) (\(achievement.threshold) steps)")
                    }
                }
            }
            
            if !newlyUnlockedAchievements.isEmpty {
                DispatchQueue.main.async {
                    for achievement in newlyUnlockedAchievements {
                        self.postAchievementNotification(
                            type: achievement.type,
                            achievementValue: achievement.value,
                            title: achievement.title,
                            description: achievement.description
                        )
                    }
                }
            }
        }
    }
    
    private func checkTotalDaysAchievements(totalDays: Int32) {
        for achievement in CoreDataManager.totalDaysAchievements {
            if totalDays >= achievement.threshold {
                let wasUnlocked = coreDataManager.isAchievementUnlocked(
                    type: "total_days",
                    targetValue: Double(achievement.threshold),
                    context: context
                )
                
                coreDataManager.unlockAchievement(
                    type: "total_days",
                    targetValue: Double(achievement.threshold),
                    context: context
                )
                
                if !wasUnlocked {
                    postAchievementNotification(
                        type: .totalDays,
                        achievementValue: Double(achievement.threshold),
                        title: achievement.title,
                        description: String(format: LocalizedKey.activeForDays.localized(), achievement.threshold)
                    )
                }
            }
        }
    }
    
    private func checkTotalDistanceAchievements(totalDistance: Double) {
        for achievement in CoreDataManager.totalDistanceAchievements {
            if totalDistance >= achievement.threshold {
                let wasUnlocked = coreDataManager.isAchievementUnlocked(
                    type: "total_distance",
                    targetValue: achievement.threshold,
                    context: context
                )
                
                coreDataManager.unlockAchievement(
                    type: "total_distance",
                    targetValue: achievement.threshold,
                    context: context
                )
                
                if !wasUnlocked {
                    postAchievementNotification(
                        type: .totalDistance,
                        achievementValue: achievement.threshold,
                        title: achievement.title,
                        description: String(format: LocalizedKey.walkedDistance.localized(), achievement.threshold)
                    )
                }
            }
        }
    }
    
    private func checkLevelAchievements(totalSteps: Int64) {
        for achievement in CoreDataManager.totalStepsAchievements {
            if totalSteps >= achievement.threshold {
                let wasUnlocked = coreDataManager.isAchievementUnlocked(
                    type: "level",
                    targetValue: Double(achievement.threshold),
                    context: context
                )
                
                coreDataManager.unlockAchievement(
                    type: "level",
                    targetValue: Double(achievement.threshold),
                    context: context
                )
                
                if !wasUnlocked {
                    postAchievementNotification(
                        type: .level,
                        achievementValue: Double(achievement.threshold),
                        title: achievement.title,
                        description: String(format: LocalizedKey.completedTotalSteps.localized(), formatSteps(achievement.threshold))
                    )
                }
            }
        }
    }
    
    // MARK: - Level Progress
    private func updateLevelProgress() {
        let progress = CoreDataManager.progressToNextLevel(currentSteps: totalSteps)
        self.levelProgress = progress.progress
        self.stepsToNextLevel = progress.stepsNeeded
        self.nextLevel = progress.nextLevel
    }
    
    // MARK: - Utility Methods
    public func formatSteps(_ steps: Int) -> String {
        if steps >= 1000000 {
            return String(format: "%.1fM", Double(steps) / 1000000.0)
        } else if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
    
    public func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.0f km", distance)
        } else if distance >= 100 {
            return String(format: "%.1f km", distance)
        }
        return String(format: "%.2f km", distance)
    }
}

// MARK: - UserStats Extension
extension UserStats {
    var levelProgressInfo: (currentLevel: Int, nextLevel: Int, progress: Double, stepsNeeded: Int) {
        return CoreDataManager.progressToNextLevel(currentSteps: totalSteps)
    }
}
