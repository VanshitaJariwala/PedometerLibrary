//
//  PedometerLibrary.swift
//  NewPedometer
//
//  Public API for using NewPedometer as a library
//

import SwiftUI
import CoreData

/// Main entry point for Pedometer Library
/// Use this class to integrate the pedometer functionality into your app
public struct PedometerLibrary {
    
    // MARK: - Initialization
    
    /// Initialize the library with Core Data context
    /// Call this method once when your app launches
    /// - Parameter context: The NSManagedObjectContext to use for Core Data operations
    public static func initialize(context: NSManagedObjectContext) {
        CoreDataManager.shared.initializeDefaultAchievements(context: context)
        CoreDataManager.shared.initializeUserStats(context: context)
    }
    
    // MARK: - View Factory Methods
    
    /// Creates and returns the main home view with step tracking functionality
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A SwiftUI view with step tracking and achievement preview
    public static func makeHomeView(context: NSManagedObjectContext) -> some View {
        HomeView()
            .environment(\.managedObjectContext, context)
    }
    
    /// Creates and returns the achievements view showing all achievement categories
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A SwiftUI view displaying all achievements
    public static func makeAchievementsView(context: NSManagedObjectContext) -> some View {
        AchievementsView()
            .environment(\.managedObjectContext, context)
    }
    
    /// Creates and returns the daily steps achievements view
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A SwiftUI view showing daily steps achievements
    public static func makeDailyStepsView(context: NSManagedObjectContext) -> some View {
        DailyStepsView()
            .environment(\.managedObjectContext, context)
    }
    
    /// Creates and returns the total days achievements view
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A SwiftUI view showing total days achievements
    public static func makeTotalDaysView(context: NSManagedObjectContext) -> some View {
        TotalDaysView()
            .environment(\.managedObjectContext, context)
    }
    
    /// Creates and returns the total distance achievements view
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A SwiftUI view showing total distance achievements
    public static func makeTotalDistanceView(context: NSManagedObjectContext) -> some View {
        TotalDistanceView()
            .environment(\.managedObjectContext, context)
    }
    
    /// Creates and returns the level view showing user's current level and progress
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A SwiftUI view displaying level information
    public static func makeLevelView(context: NSManagedObjectContext) -> some View {
        LevelView()
            .environment(\.managedObjectContext, context)
    }
    
    // MARK: - ViewModel Factory Methods
    
    /// Creates a StepTrackingViewModel instance
    /// Use this to track steps, distance, and manage user stats
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A configured StepTrackingViewModel
    public static func makeStepTrackingViewModel(context: NSManagedObjectContext) -> StepTrackingViewModel {
        return StepTrackingViewModel(context: context)
    }
    
    /// Creates an AchievementViewModel instance
    /// Use this to query achievements and progress
    /// - Parameter context: The NSManagedObjectContext for Core Data
    /// - Returns: A configured AchievementViewModel
    public static func makeAchievementViewModel(context: NSManagedObjectContext) -> AchievementViewModel {
        return AchievementViewModel(context: context)
    }
    
    // MARK: - Core Data Helpers
    
    /// Creates a PedometerPersistenceController instance
    /// Use this if you want to use the library's Core Data setup
    /// - Parameter modelName: The name of your Core Data model (default: "NewPedometer")
    /// - Returns: A configured PedometerPersistenceController
    public static func makePersistenceController(modelName: String = "NewPedometer") -> PedometerPersistenceController {
        return PedometerPersistenceController()
    }
    
    /// Gets the shared PedometerPersistenceController instance
    /// - Returns: The shared PedometerPersistenceController
    public static func sharedPersistenceController() -> PedometerPersistenceController {
        return PedometerPersistenceController.shared
    }
}

// MARK: - Convenience Extensions

extension PedometerLibrary {
    
    /// Quick setup method that initializes everything
    /// - Parameters:
    ///   - context: The NSManagedObjectContext for Core Data
    ///   - autoInitialize: Whether to automatically initialize achievements and user stats (default: true)
    public static func setup(context: NSManagedObjectContext, autoInitialize: Bool = true) {
        if autoInitialize {
            initialize(context: context)
        }
    }
}

