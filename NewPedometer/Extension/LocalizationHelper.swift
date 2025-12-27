//
//  LocalizationHelper.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 21/12/25.
//

import Foundation
import SwiftUI

// MARK: - String Extension for Localization
extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}

// MARK: - Convenience Functions for Common Format Patterns
extension LocalizedKey {
    static func format(_ key: String, _ value: String) -> String {
        return String(format: key.localized(), value)
    }
    
    static func format(_ key: String, _ value: Int) -> String {
        return String(format: key.localized(), value)
    }
    
    static func format(_ key: String, _ value: Double) -> String {
        return String(format: key.localized(), value)
    }
}

// MARK: - Localization Keys
enum LocalizedKey {
    // Common UI
    static let ok = "button.ok"
    static let cancel = "button.cancel"
    static let done = "button.done"
    static let submit = "button.submit"
    static let `continue` = "button.continue"
    static let save = "button.save"
    static let saving = "button.saving"
    static let more = "button.more"
    static let viewAll = "button.view_all"
    
    // Navigation
    static let achievements = "nav.achievements"
    static let level = "nav.level"
    static let dailySteps = "nav.daily_steps"
    static let totalDays = "nav.total_days"
    static let totalDistance = "nav.total_distance"
    static let home = "nav.home"
    static let achievementModule = "nav.achievement_module"
    
    // Form Labels
    static let formDailySteps = "form.daily_steps"
    static let formLifetimeSteps = "form.lifetime_steps"
    static let formTotalDistance = "form.total_distance"
    static let formDays = "form.days"
    static let formAchievement = "form.achievement"
    
    // Achievement Messages
    static let congratulations = "achievement.congratulations"
    static let reachedNewBadge = "achievement.reached_new_badge"
    static let reachedBadge = "achievement.reached_badge"
    static let completedSteps = "achievement.completed_steps"
    static let completedStepsToday = "achievement.completed_steps_today"
    static let activeForDays = "achievement.active_for_days"
    static let walkedDistance = "achievement.walked_distance"
    static let completedTotalSteps = "achievement.completed_total_steps"
    
    // Progress Messages
    static let moreStepsToLevel = "progress.more_steps_to_level"
    static let moreStepsToWin = "progress.more_steps_to_win"
    static let moreDaysToAchieve = "progress.more_days_to_achieve"
    static let moreKmToAchieve = "progress.more_km_to_achieve"
    static let stepsLeft = "progress.steps_left"
    static let daysLeft = "progress.days_left"
    static let kmLeft = "progress.km_left"
    static let maximumLevelAchieved = "progress.maximum_level_achieved"
    static let allDailyCompleted = "progress.all_daily_completed"
    static let allDaysCompleted = "progress.all_days_completed"
    static let allDistanceCompleted = "progress.all_distance_completed"
    static let allAchievementsCompleted = "progress.all_achievements_completed"
    static let allDailyCompletedToday = "progress.all_daily_completed_today"
    
    // Achievement Titles
    static let firstFootprint = "achievement.title.first_footprint"
    static let stepWarrior = "achievement.title.step_warrior"
    static let paceMaster = "achievement.title.pace_master"
    static let strideChampion = "achievement.title.stride_champion"
    static let trailBlazer = "achievement.title.trail_blazer"
    static let stepTitan = "achievement.title.step_titan"
    static let enduranceHero = "achievement.title.endurance_hero"
    static let legendWalker = "achievement.title.legend_walker"
    static let weeklyWalker = "achievement.title.weekly_walker"
    static let twoWeekTrekker = "achievement.title.two_week_trekker"
    static let monthlyMover = "achievement.title.monthly_mover"
    static let biMonthlyBlazer = "achievement.title.bi_monthly_blazer"
    static let centuryStepper = "achievement.title.century_stepper"
    static let halfYearHero = "achievement.title.half_year_hero"
    static let annualAchiever = "achievement.title.annual_achiever"
    static let legendaryStrider = "achievement.title.legendary_strider"
    static let millenniumWalker = "achievement.title.millennium_walker"
    static let miniTrekker = "achievement.title.mini_trekker"
    static let pathSeeker = "achievement.title.path_seeker"
    static let journeyMaker = "achievement.title.journey_maker"
    static let marathoner = "achievement.title.marathoner"
    static let roadChallenger = "achievement.title.road_challenger"
    static let cityConnector = "achievement.title.city_connector"
    static let continentStrider = "achievement.title.continent_strider"
    static let desertVoyager = "achievement.title.desert_voyager"
    static let countryCrawler = "achievement.title.country_crawler"
    static let worldWanderer = "achievement.title.world_wanderer"
    static let start = "achievement.title.start"
    static let steps10k = "achievement.title.10k_steps"
    static let steps50k = "achievement.title.50k_steps"
    static let steps100k = "achievement.title.100k_steps"
    static let steps170k = "achievement.title.170k_steps"
    static let steps220k = "achievement.title.220k_steps"
    static let steps330k = "achievement.title.330k_steps"
    static let steps440k = "achievement.title.440k_steps"
    static let steps550k = "achievement.title.550k_steps"
    static let steps660k = "achievement.title.660k_steps"
    static let steps770k = "achievement.title.770k_steps"
    static let steps880k = "achievement.title.880k_steps"
    static let steps990k = "achievement.title.990k_steps"
    static let steps1100k = "achievement.title.1100k_steps"
    static let steps1200k = "achievement.title.1200k_steps"
    static let steps1300k = "achievement.title.1300k_steps"
    static let steps1400k = "achievement.title.1400k_steps"
    static let steps1500k = "achievement.title.1500k_steps"
    static let steps1600k = "achievement.title.1600k_steps"
    static let steps2000k = "achievement.title.2000k_steps"
    
    // Level Messages
    static let stepsRequired = "level.steps_required"
    static let achievedDate = "level.achieved_date"
    
    // Alert Messages
    static let success = "alert.success"
    static let error = "alert.error"
    static let lockedAchievement = "alert.locked_achievement"
    static let lockedMessage = "alert.locked_message"
    static let lockedMessageSteps = "alert.locked_message_steps"
    static let lockedMessageDays = "alert.locked_message_days"
    static let lockedMessageDistance = "alert.locked_message_distance"
    static let enterPositiveValue = "alert.enter_positive_value"
    static let progressAdded = "alert.progress_added"
    
    // Stats Labels
    static let totalSteps = "stats.total_steps"
    static let distance = "stats.distance"
    static let days = "stats.days"
    static let levelStat = "stats.level"
    static let currentStats = "stats.current_stats"
    static let stepsToLevel = "stats.steps_to_level"
    
    // Share Messages
    static let shareLevelAchievement = "share.level_achievement"
    static let shareAchievementGeneric = "share.achievement_generic"
    static let shareAchievementCompleted = "share.achievement_completed"
    static let shareLevelReached = "share.level_reached"
    static let shareDailySteps = "share.daily_steps"
    static let shareTotalDays = "share.total_days"
    static let shareTotalDistance = "share.total_distance"
    
    // Notification Titles
    static let notificationLevelUp = "notification.level_up"
    static let notificationDailyGoal = "notification.daily_goal"
    static let notificationMilestone = "notification.milestone"
    static let notificationDistanceGoal = "notification.distance_goal"
    
    // Notification Bodies
    static let notificationLevelBody = "notification.level_body"
    static let notificationDailyBody = "notification.daily_body"
    static let notificationDaysBody = "notification.days_body"
    static let notificationDistanceBody = "notification.distance_body"
    
    // MARK: - Helper Functions for Localizing Achievement/Level Names
    
    static func localizeAchievementTitle(_ title: String) -> String {
        switch title {
        case "First Footprint": return firstFootprint.localized()
        case "Step Warrior": return stepWarrior.localized()
        case "Pace Master": return paceMaster.localized()
        case "Stride Champion": return strideChampion.localized()
        case "Trail Blazer": return trailBlazer.localized()
        case "Step Titan": return stepTitan.localized()
        case "Endurance Hero": return enduranceHero.localized()
        case "Legend Walker": return legendWalker.localized()
        case "Weekly Walker": return weeklyWalker.localized()
        case "Two Week Trekker": return twoWeekTrekker.localized()
        case "Monthly Mover": return monthlyMover.localized()
        case "Bi-Monthly Blazer": return biMonthlyBlazer.localized()
        case "Century Stepper": return centuryStepper.localized()
        case "Half Year Hero": return halfYearHero.localized()
        case "Annual Achiever": return annualAchiever.localized()
        case "Legendary Strider": return legendaryStrider.localized()
        case "Millennium Walker": return millenniumWalker.localized()
        case "Mini Trekker": return miniTrekker.localized()
        case "Path Seeker": return pathSeeker.localized()
        case "Journey Maker": return journeyMaker.localized()
        case "Marathoner": return marathoner.localized()
        case "Road Challenger": return roadChallenger.localized()
        case "City Connector": return cityConnector.localized()
        case "Continent Strider": return continentStrider.localized()
        case "Desert Voyager": return desertVoyager.localized()
        case "Country Crawler": return countryCrawler.localized()
        case "World Wanderer": return worldWanderer.localized()
        default: return title
        }
    }
    
    static func localizeLevelName(_ name: String) -> String {
        switch name {
        case "Start": return start.localized()
        case "10k Steps": return steps10k.localized()
        case "50k Steps": return steps50k.localized()
        case "100k Steps": return steps100k.localized()
        case "170k Steps": return steps170k.localized()
        case "220k Steps": return steps220k.localized()
        case "330k Steps": return steps330k.localized()
        case "440k Steps": return steps440k.localized()
        case "550k Steps": return steps550k.localized()
        case "660k Steps": return steps660k.localized()
        case "770k Steps": return steps770k.localized()
        case "880k Steps": return steps880k.localized()
        case "990k Steps": return steps990k.localized()
        case "1100k Steps": return steps1100k.localized()
        case "1200k Steps": return steps1200k.localized()
        case "1300k Steps": return steps1300k.localized()
        case "1400k Steps": return steps1400k.localized()
        case "1500k Steps": return steps1500k.localized()
        case "1600k Steps": return steps1600k.localized()
        case "2000k Steps": return steps2000k.localized()
        default: return name 
        }
    }
}

