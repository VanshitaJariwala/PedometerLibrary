//
//  Persistence.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import CoreData

// MARK: - PersistenceController
public struct PersistenceController {
    public static let shared = PersistenceController()

    @MainActor
    public static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Setup preview data
        CoreDataManager.shared.initializeDefaultAchievements(context: viewContext)
        CoreDataManager.shared.initializeUserStats(context: viewContext)
        
        return result
    }()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NewPedometer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("CoreData Error: \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// MARK: - CoreDataManager
public final class CoreDataManager {
    public static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Achievement Definitions
    
    /// Daily steps achievement thresholds and titles
    public static let dailyStepsAchievements: [(threshold: Int, title: String, unlockImage: String, lockImage: String)] = [
        (3000, "First Footprint", "badge3kUnlock", "badge3kLock"),
        (7000, "Step Warrior", "badge7kUnlock", "badge7kLock"),
        (10000, "Pace Master", "badge10kUnlock", "badge10kLock"),
        (14000, "Stride Champion", "badge14kUnlock", "badge14kLock"),
        (20000, "Trail Blazer", "badge20kUnlock", "badge20kLock"),
        (30000, "Step Titan", "badge30kUnlock", "badge30kLock"),
        (40000, "Endurance Hero", "badge40kUnlock", "badge40kLock"),
        (60000, "Legend Walker", "badge60kUnlock", "badge60kLock")
    ]
    
    /// Total steps achievement thresholds (based on level system)
    public static let totalStepsAchievements: [(threshold: Int, title: String, level: Int)] = [
        (0, "Start", 1),
        (10000, "10k Steps", 2),
        (50000, "50k Steps", 3),
        (100000, "100k Steps", 4),
        (170000, "170k Steps", 5),
        (220000, "220k Steps", 6),
        (330000, "330k Steps", 7),
        (440000, "440k Steps", 8),
        (550000, "550k Steps", 9),
        (660000, "660k Steps", 10),
        (770000, "770k Steps", 11),
        (880000, "880k Steps", 12),
        (990000, "990k Steps", 13),
        (1100000, "1100k Steps", 14),
        (1200000, "1200k Steps", 15),
        (1300000, "1300k Steps", 16),
        (1400000, "1400k Steps", 17),
        (1500000, "1500k Steps", 18),
        (1600000, "1600k Steps", 19),
        (2000000, "2000k Steps", 20)
    ]
    
    /// Total days achievement thresholds
    public static let totalDaysAchievements: [(threshold: Int, title: String, unlockImage: String, lockImage: String)] = [
        (7, "7 Days", "days7Unlock", "days7Lock"),
        (14, "14 Days", "days14Unlock", "days14Lock"),
        (30, "30 Days", "days30Unlock", "days30Lock"),
        (60, "60 Days", "days60Unlock", "days60Lock"),
        (100, "100 Days", "days100Unlock", "days100Lock"),
        (180, "180 Days", "days180Unlock", "days180Lock"),
        (365, "365 Days", "days365Unlock", "days365Lock"),
        (500, "500 Days", "days500Unlock", "days500Lock"),
        (1000, "1000 Days", "days1000Unlock", "days1000Lock")
    ]
    
    /// Total distance achievement thresholds (in km)
    public static let totalDistanceAchievements: [(threshold: Double, title: String, unlockImage: String, lockImage: String)] = [
        (3.0, "Mini Trekker", "miles3Unlock", "miles3Lock"),
        (5.0, "Path Seeker", "miles5Unlock", "miles5Lock"),
        (12.0, "Journey Maker", "miles12Unlock", "miles12Lock"),
        (26.0, "Marathoner", "miles26Unlock", "miles26Lock"),
        (60.0, "Road Challenger", "miles60Unlock", "miles60Lock"),
        (135.0, "City Connector", "miles135Unlock", "miles135Lock"),
        (280.0, "Continent Strider", "miles280Unlock", "miles280Lock"),
        (500.0, "Desert Voyager", "miles500Unlock", "miles500Lock"),
        (1200.0, "Country Crawler", "miles1200Unlock", "miles1200Lock"),
        (3950.0, "World Wanderer", "miles3950Unlock", "miles3950Lock")
    ]
    
    // MARK: - Save Context
    
    /// Safely saves the managed object context
    public func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - UserStats Operations
    
    /// Fetches or creates the single UserStats record
    public func fetchOrCreateUserStats(context: NSManagedObjectContext) -> UserStats {
        let request: NSFetchRequest<UserStats> = UserStats.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let existingStats = results.first {
                return existingStats
            }
        } catch {
            print("Error fetching UserStats: \(error)")
        }
        
        // Create new UserStats if none exists
        let newStats = UserStats(context: context)
        newStats.totalSteps = 0
        newStats.totalDistance = 0.0
        newStats.totalDays = 0
        newStats.currentLevel = 1
        newStats.highestDailySteps = 0
        saveContext(context)
        
        return newStats
    }
    
    /// Initializes UserStats with default values (used for preview/first launch)
    public func initializeUserStats(context: NSManagedObjectContext) {
        let _ = fetchOrCreateUserStats(context: context)
    }
    
    // MARK: - StepRecord Operations
    
    /// Fetches step record for a specific date
    public func fetchStepRecord(for date: Date, context: NSManagedObjectContext) -> StepRecord? {
        let request: NSFetchRequest<StepRecord> = StepRecord.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching step record: \(error)")
            return nil
        }
    }
    
    /// Creates or updates a step record for a specific date
    public func createOrUpdateStepRecord(date: Date, steps: Int64, distance: Double, context: NSManagedObjectContext) -> StepRecord {
        if let existingRecord = fetchStepRecord(for: date, context: context) {
            existingRecord.steps = steps
            existingRecord.distance = distance
            return existingRecord
        }
        
        let newRecord = StepRecord(context: context)
        newRecord.date = Calendar.current.startOfDay(for: date)
        newRecord.steps = steps
        newRecord.distance = distance
        return newRecord
    }
    
    /// Fetches all step records sorted by date
    func fetchAllStepRecords(context: NSManagedObjectContext) -> [StepRecord] {
        let request: NSFetchRequest<StepRecord> = StepRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StepRecord.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching step records: \(error)")
            return []
        }
    }
    
    /// Counts unique days with step records
    func countActiveDays(context: NSManagedObjectContext) -> Int {
        let request: NSFetchRequest<StepRecord> = StepRecord.fetchRequest()
        request.predicate = NSPredicate(format: "steps > 0")
        
        do {
            let records = try context.fetch(request)
            let uniqueDays = Set(records.compactMap { record -> Date? in
                guard let date = record.date else { return nil }
                return Calendar.current.startOfDay(for: date)
            })
            return uniqueDays.count
        } catch {
            print("Error counting active days: \(error)")
            return 0
        }
    }
    
    // MARK: - Achievement Operations
    
    /// Fetches all achievements
    func fetchAllAchievements(context: NSManagedObjectContext) -> [Achievement] {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Achievement.targetValue, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching achievements: \(error)")
            return []
        }
    }
    
    /// Fetches achievements by type
    func fetchAchievements(byType type: String, context: NSManagedObjectContext) -> [Achievement] {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Achievement.targetValue, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching achievements by type: \(error)")
            return []
        }
    }
    
    /// Creates an achievement if it doesn't exist
    func createAchievementIfNeeded(
        type: String,
        title: String,
        targetValue: Double,
        unlockedImageName: String,
        lockedImageName: String,
        context: NSManagedObjectContext
    ) {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@ AND targetValue == %lf", type, targetValue)
        
        do {
            let existing = try context.fetch(request)
            if existing.isEmpty {
                let achievement = Achievement(context: context)
                achievement.id = UUID()
                achievement.type = type
                achievement.title = title
                achievement.targetValue = targetValue
                achievement.isUnlocked = false
                achievement.unlockedImageName = unlockedImageName
                achievement.lockedImageName = lockedImageName
            }
        } catch {
            print("Error creating achievement: \(error)")
        }
    }
    
    /// Initializes all default achievements on first launch
    public func initializeDefaultAchievements(context: NSManagedObjectContext) {
        // Daily Steps Achievements
        for achievement in Self.dailyStepsAchievements {
            createAchievementIfNeeded(
                type: "daily_steps",
                title: achievement.title,
                targetValue: Double(achievement.threshold),
                unlockedImageName: achievement.unlockImage,
                lockedImageName: achievement.lockImage,
                context: context
            )
        }
        
        // Total Days Achievements
        for achievement in Self.totalDaysAchievements {
            createAchievementIfNeeded(
                type: "total_days",
                title: achievement.title,
                targetValue: Double(achievement.threshold),
                unlockedImageName: achievement.unlockImage,
                lockedImageName: achievement.lockImage,
                context: context
            )
        }
        
        // Total Distance Achievements
        for achievement in Self.totalDistanceAchievements {
            createAchievementIfNeeded(
                type: "total_distance",
                title: achievement.title,
                targetValue: achievement.threshold,
                unlockedImageName: achievement.unlockImage,
                lockedImageName: achievement.lockImage,
                context: context
            )
        }
        
        // Level Achievements (Total Steps)
        for achievement in Self.totalStepsAchievements {
            createAchievementIfNeeded(
                type: "level",
                title: achievement.title,
                targetValue: Double(achievement.threshold),
                unlockedImageName: "LV_\(achievement.level)",
                lockedImageName: "LV_\(achievement.level)",
                context: context
            )
        }
        
        saveContext(context)
    }
    
    /// Unlocks an achievement by type and target value
    func unlockAchievement(type: String, targetValue: Double, context: NSManagedObjectContext) {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@ AND targetValue == %lf AND isUnlocked == NO", type, targetValue)
        
        do {
            let achievements = try context.fetch(request)
            for achievement in achievements {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
            }
            saveContext(context)
        } catch {
            print("Error unlocking achievement: \(error)")
        }
    }
    
    /// Checks if an achievement is unlocked
    func isAchievementUnlocked(type: String, targetValue: Double, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@ AND targetValue == %lf", type, targetValue)
        request.fetchLimit = 1
        
        do {
            let achievements = try context.fetch(request)
            return achievements.first?.isUnlocked ?? false
        } catch {
            print("Error checking achievement: \(error)")
            return false
        }
    }
    
    // MARK: - Utility Functions
    
    /// Calculates distance from steps (average stride length: 0.762m = 2.5 feet)
    public static func calculateDistance(fromSteps steps: Int64) -> Double {
        let averageStrideMeters = 0.762
        let distanceMeters = Double(steps) * averageStrideMeters
        let distanceKm = distanceMeters / 1000.0
        return round(distanceKm * 100) / 100 // Round to 2 decimal places
    }
    
    /// Calculates level based on total steps
    public static func calculateLevel(fromTotalSteps totalSteps: Int64) -> Int {
        var level = 1
        for achievement in totalStepsAchievements {
            if totalSteps >= achievement.threshold {
                level = achievement.level
            } else {
                break
            }
        }
        return level
    }
    
    /// Gets the step requirement for a specific level
    static func stepsRequiredForLevel(_ level: Int) -> Int {
        return totalStepsAchievements.first { $0.level == level }?.threshold ?? 0
    }
    
    /// Gets progress to next level
    public static func progressToNextLevel(currentSteps: Int64) -> (currentLevel: Int, nextLevel: Int, progress: Double, stepsNeeded: Int) {
        let currentLevel = calculateLevel(fromTotalSteps: currentSteps)
        
        if currentLevel >= 20 {
            return (20, 20, 1.0, 0)
        }
        
        let currentLevelSteps = stepsRequiredForLevel(currentLevel)
        let nextLevelSteps = stepsRequiredForLevel(currentLevel + 1)
        let stepsInBand = Int(currentSteps) - currentLevelSteps
        let totalBandSteps = max(1, nextLevelSteps - currentLevelSteps)
        let progress = Double(stepsInBand) / Double(totalBandSteps)
        let stepsNeeded = max(0, nextLevelSteps - Int(currentSteps))
        
        return (currentLevel, currentLevel + 1, min(1.0, progress), stepsNeeded)
    }
}
