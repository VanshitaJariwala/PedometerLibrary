//
//  AchievementViewModel.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import Foundation
import CoreData
import Combine

// MARK: - Achievement Progress Result
public struct AchievementProgressResult {
    let progress: Double
    let remainingValue: Double
    let remainingText: String
    let isAllCompleted: Bool
    let nextTargetValue: Double
    let nextTitle: String
}

// MARK: - Achievement Display Model
public struct AchievementDisplayModel: Identifiable {
    public let id: UUID
    let type: String
    let title: String
    let targetValue: Double
    let isUnlocked: Bool
    let unlockedDate: Date?
    let unlockedImageName: String
    let lockedImageName: String
    
    var currentImageName: String {
        isUnlocked ? unlockedImageName : lockedImageName
    }
    
    var formattedTarget: String {
        switch type {
        case "daily_steps", "level":
            return formatSteps(Int(targetValue))
        case "total_days":
            return "\(Int(targetValue))"
        case "total_distance":
            return String(format: "%.0f", targetValue)
        default:
            return "\(Int(targetValue))"
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
}

// MARK: - Level Display Model
public struct LevelDisplayModel: Identifiable {
    public let id: Int  // Level number
    let levelName: String
    let stepRequirement: Int
    let imageName: String
    var isUnlocked: Bool
    var unlockedDate: Date?
}

// MARK: - AchievementViewModel
@MainActor
public final class AchievementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All daily steps achievements
    @Published var dailyStepsAchievements: [AchievementDisplayModel] = []
    
    /// All total days achievements
    @Published var totalDaysAchievements: [AchievementDisplayModel] = []
    
    /// All total distance achievements
    @Published var totalDistanceAchievements: [AchievementDisplayModel] = []
    
    /// All level achievements
    @Published var levels: [LevelDisplayModel] = []
    
    /// Current user stats
    @Published var dailySteps: Double = 0.0
    @Published var lifetimeSteps: Double = 0.0
    @Published var totalDistance: Double = 0.0
    @Published var totalDays: Int32 = 0
    @Published var currentLevel: Int = 1
    @Published var highestDailySteps: Int64 = 0
    
    /// Level progress
    @Published var stepsToNextLevel: Int = 0
    @Published var levelProgress: Double = 0.0
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Initialization
    
    public init(context: NSManagedObjectContext) {
        self.context = context
        initializeIfNeeded()
        loadAllData()
    }
    
    // MARK: - Public Methods
    
    public func initializeIfNeeded() {
        context.perform { [weak self] in
            guard let self = self else { return }
            self.coreDataManager.initializeDefaultAchievements(context: self.context)
            self.coreDataManager.initializeUserStats(context: self.context)
        }
    }
    
    public func loadAllData() {
        isLoading = true
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let userStats = self.coreDataManager.fetchOrCreateUserStats(context: self.context)
            
            let todayRecord = self.coreDataManager.fetchStepRecord(for: Date(), context: self.context)
            let todaySteps = todayRecord?.steps ?? 0
            
            let dailySteps = self.loadAchievements(type: "daily_steps")
            let totalDays = self.loadAchievements(type: "total_days")
            let totalDistance = self.loadAchievements(type: "total_distance")
            let levelAchievements = self.loadLevelAchievements()
            
            let progress = CoreDataManager.progressToNextLevel(currentSteps: userStats.totalSteps)
            
            DispatchQueue.main.async {
                self.dailySteps = Double(todaySteps)
                self.lifetimeSteps = Double(userStats.totalSteps)
                self.totalDistance = userStats.totalDistance
                self.totalDays = userStats.totalDays
                self.currentLevel = Int(userStats.currentLevel)
                self.highestDailySteps = userStats.highestDailySteps
                
                self.dailyStepsAchievements = dailySteps
                self.totalDaysAchievements = totalDays
                self.totalDistanceAchievements = totalDistance
                self.levels = levelAchievements
                
                self.levelProgress = progress.progress
                self.stepsToNextLevel = progress.stepsNeeded
                
                self.isLoading = false
            }
        }
    }
    
    public func refresh() {
        loadAllData()
    }
    
    // MARK: - PROGRESS CALCULATION (Based on NEXT LOCKED Achievement)
    public func getNextAchievementProgress(type: AchievementType, currentValue: Double) -> AchievementProgressResult {
        let achievements: [AchievementDisplayModel]
        let unit: String
        
        switch type {
        case .dailySteps:
            achievements = dailyStepsAchievements
            unit = "steps"
        case .totalDays:
            achievements = totalDaysAchievements
            unit = "Days"
        case .totalDistance:
            achievements = totalDistanceAchievements
            unit = "km"
        case .level:
            return getLevelProgress()
        }
        
        let sortedAchievements = achievements.sorted { $0.targetValue < $1.targetValue }
        
        guard let nextLocked = sortedAchievements.first(where: { !$0.isUnlocked }) else {
            return AchievementProgressResult(
                progress: 1.0,
                remainingValue: 0,
                remainingText: String(format: LocalizedKey.allAchievementsCompleted.localized(), type.displayName),
                isAllCompleted: true,
                nextTargetValue: 0,
                nextTitle: ""
            )
        }
        
        let targetValue = nextLocked.targetValue
        let progress = clamp(currentValue / targetValue, min: 0.0, max: 1.0)
        let remaining = max(0, targetValue - currentValue)
        
        let remainingText: String
        switch type {
        case .dailySteps:
            remainingText = String(format: LocalizedKey.stepsLeft.localized(), formatSteps(Int(remaining)))
        case .totalDays:
            remainingText = String(format: LocalizedKey.daysLeft.localized(), Int(remaining))
        case .totalDistance:
            remainingText = String(format: LocalizedKey.kmLeft.localized(), remaining)
        case .level:
            remainingText = ""
        }
        
        return AchievementProgressResult(
            progress: progress,
            remainingValue: remaining,
            remainingText: remainingText,
            isAllCompleted: false,
            nextTargetValue: targetValue,
            nextTitle: nextLocked.title
        )
    }
    
    // MARK: - 1️⃣ Daily Steps Progress
    public func getDailyStepsProgress() -> AchievementProgressResult {
        let sortedAchievements = dailyStepsAchievements.sorted { $0.targetValue < $1.targetValue }
        let todaySteps = dailySteps
        
        guard let nextAchievement = sortedAchievements.first(where: { todaySteps < $0.targetValue }) else {
            return AchievementProgressResult(
                progress: 1.0,
                remainingValue: 0,
                remainingText: LocalizedKey.allDailyCompletedToday.localized(),
                isAllCompleted: true,
                nextTargetValue: 0,
                nextTitle: ""
            )
        }
        
        let targetValue = nextAchievement.targetValue
        let progress = clamp(todaySteps / targetValue, min: 0.0, max: 1.0)
        let remaining = max(0, targetValue - todaySteps)
        
        let remainingText = String(format: LocalizedKey.stepsLeft.localized(), formatSteps(Int(remaining)))
        
        return AchievementProgressResult(
            progress: progress,
            remainingValue: remaining,
            remainingText: remainingText,
            isAllCompleted: false,
            nextTargetValue: targetValue,
            nextTitle: nextAchievement.title
        )
    }
    
    var dailyStepsProgressValue: Double {
        return getDailyStepsProgress().progress
    }
    
    var dailyStepsRemainingText: String {
        return getDailyStepsProgress().remainingText
    }
    
    // MARK: - 2️⃣ Total Days Progress
    public func getTotalDaysProgress() -> AchievementProgressResult {
        return getNextAchievementProgress(type: .totalDays, currentValue: Double(totalDays))
    }
    
    var totalDaysProgressValue: Double {
        return getTotalDaysProgress().progress
    }
    
    var totalDaysRemainingText: String {
        return getTotalDaysProgress().remainingText
    }
    
    // MARK: - 3️⃣ Total Distance Progress
    public func getTotalDistanceProgress() -> AchievementProgressResult {
        return getNextAchievementProgress(type: .totalDistance, currentValue: totalDistance)
    }
    
    var totalDistanceProgressValue: Double {
        return getTotalDistanceProgress().progress
    }
    
    var totalDistanceRemainingText: String {
        return getTotalDistanceProgress().remainingText
    }
    
    // MARK: - 4️⃣ Level Progress (Special Handling)
    public func getLevelProgress() -> AchievementProgressResult {
        let currentSteps = Int(lifetimeSteps)
        
        let sortedLevels = levels.sorted { $0.id < $1.id }
        
        guard let nextLockedLevel = sortedLevels.first(where: { !$0.isUnlocked }) else {
            return AchievementProgressResult(
                progress: 1.0,
                remainingValue: 0,
                remainingText: LocalizedKey.maximumLevelAchieved.localized(),
                isAllCompleted: true,
                nextTargetValue: 0,
                nextTitle: ""
            )
        }
        
        let currentLevelIndex = max(0, nextLockedLevel.id - 2) // -2 because level IDs start at 1
        let currentLevelSteps = currentLevelIndex >= 0 && currentLevelIndex < sortedLevels.count
            ? sortedLevels[currentLevelIndex].stepRequirement
            : 0
        
        let nextLevelSteps = nextLockedLevel.stepRequirement
        let stepsInBand = currentSteps - currentLevelSteps
        let totalBandSteps = max(1, nextLevelSteps - currentLevelSteps)
        
        let progress = clamp(Double(stepsInBand) / Double(totalBandSteps), min: 0.0, max: 1.0)
        let remaining = max(0, nextLevelSteps - currentSteps)
        
        let remainingText = String(format: LocalizedKey.moreStepsToLevel.localized(), formatSteps(remaining), nextLockedLevel.id)
        
        return AchievementProgressResult(
            progress: progress,
            remainingValue: Double(remaining),
            remainingText: remainingText,
            isAllCompleted: false,
            nextTargetValue: Double(nextLevelSteps),
            nextTitle: nextLockedLevel.levelName
        )
    }
    
    var levelProgressValue: Double {
        return getLevelProgress().progress
    }
    
    var levelRemainingText: String {
        return getLevelProgress().remainingText
    }
    
    // MARK: - UTILITY FUNCTIONS
    private func clamp(_ value: Double, min minVal: Double, max maxVal: Double) -> Double {
        return max(minVal, min(maxVal, value))
    }
    
    public func formatSteps(_ steps: Int) -> String {
        if steps >= 1000000 {
            return String(format: "%.1fM", Double(steps) / 1000000.0)
        } else if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
    
    // MARK: - Legacy Methods (Kept for compatibility)
    func isDailyStepsAchievementUnlocked(threshold: Int) -> Bool {
        return dailySteps >= Double(threshold)
    }
    
    func isTotalDaysAchievementUnlocked(threshold: Int) -> Bool {
        return totalDays >= threshold
    }
    
    func isDistanceAchievementUnlocked(threshold: Double) -> Bool {
        return totalDistance >= threshold
    }
    
    // MARK: - Private Methods
    private func loadAchievements(type: String) -> [AchievementDisplayModel] {
        let achievements = coreDataManager.fetchAchievements(byType: type, context: context)
        
        return achievements.map { achievement in
            AchievementDisplayModel(
                id: achievement.id ?? UUID(),
                type: achievement.type ?? type,
                title: achievement.title ?? "",
                targetValue: achievement.targetValue,
                isUnlocked: achievement.isUnlocked,
                unlockedDate: achievement.unlockedDate,
                unlockedImageName: achievement.unlockedImageName ?? "",
                lockedImageName: achievement.lockedImageName ?? ""
            )
        }
    }
    
    private func loadLevelAchievements() -> [LevelDisplayModel] {
        let userStats = coreDataManager.fetchOrCreateUserStats(context: context)
        let totalSteps = userStats.totalSteps
        
        return CoreDataManager.totalStepsAchievements.map { levelData in
            LevelDisplayModel(
                id: levelData.level,
                levelName: levelData.title,
                stepRequirement: levelData.threshold,
                imageName: "LV_\(levelData.level)",
                isUnlocked: totalSteps >= levelData.threshold,
                unlockedDate: totalSteps >= levelData.threshold ? Date() : nil
            )
        }
    }
}

// MARK: - Achievement Type Enum
public enum AchievementType: String, CaseIterable {
    case dailySteps = "daily_steps"
    case totalDays = "total_days"
    case totalDistance = "total_distance"
    case level = "level"
    
    var displayName: String {
        switch self {
        case .dailySteps: return LocalizedKey.dailySteps.localized()
        case .totalDays: return LocalizedKey.totalDays.localized()
        case .totalDistance: return LocalizedKey.totalDistance.localized()
        case .level: return LocalizedKey.level.localized()
        }
    }
}
