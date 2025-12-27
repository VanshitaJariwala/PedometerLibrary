//
//  HomeView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData
import UIKit

public struct HomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState private var focusedField: Field?
    @State private var dailySteps: String = ""
    @State private var lifetimeSteps: String = ""
    @State private var totalDistance: String = ""
    @State private var days: String = ""
    @State private var showAchievements = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage: String = ""
    
    @StateObject private var stepViewModel: StepTrackingViewModel
    @StateObject private var achievementViewModel: AchievementViewModel
    
    enum Field {
        case dailySteps, lifetimeSteps, totalDistance, days
    }
    
    public init() {
        let context = PedometerPersistenceController.shared.container.viewContext
        _stepViewModel = StateObject(wrappedValue: StepTrackingViewModel(context: context))
        _achievementViewModel = StateObject(wrappedValue: AchievementViewModel(context: context))
    }
    
    public var body: some View {
        mainContent
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(LocalizedKey.done.localized()) {
                        focusedField = nil
                    }
                }
            }
            .alert(LocalizedKey.success.localized(), isPresented: $showSuccessAlert) {
                Button(LocalizedKey.ok.localized(), role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert(LocalizedKey.error.localized(), isPresented: $showErrorAlert) {
                Button(LocalizedKey.ok.localized(), role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                CoreDataManager.shared.initializeDefaultAchievements(context: viewContext)
                CoreDataManager.shared.initializeUserStats(context: viewContext)
                stepViewModel.refresh()
                achievementViewModel.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                stepViewModel.refresh()
                achievementViewModel.refresh()
            }
            .onChange(of: stepViewModel.successMessage) { newValue in
                if let message = newValue {
                    alertMessage = message
                    showSuccessAlert = true
                    stepViewModel.successMessage = nil
                    // Refresh achievement view model when data is successfully added
                    achievementViewModel.refresh()
                }
            }
            .onChange(of: stepViewModel.errorMessage) { newValue in
                if let message = newValue {
                    alertMessage = message
                    showErrorAlert = true
                    stepViewModel.errorMessage = nil
                }
            }
            .onChange(of: stepViewModel.isLoading) { isLoading in
                // When loading completes (data saved), refresh achievement view model
                if !isLoading {
                    // Small delay to ensure CoreData save is complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        achievementViewModel.refresh()
                    }
                }
            }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            Color(hex: "F3F5F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text(LocalizedKey.achievementModule.localized())
                        .font(.system(size: 22, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 30)
                    
                    // DAILY STEPS
                    TextField(LocalizedKey.formDailySteps.localized(), text: $dailySteps)
                        .textFieldStyle()
                        .focused($focusedField, equals: .dailySteps)
                    
                    // LIFETIME STEPS
                    TextField(LocalizedKey.formLifetimeSteps.localized(), text: $lifetimeSteps)
                        .textFieldStyle()
                        .focused($focusedField, equals: .lifetimeSteps)
                    
                    // TOTAL DISTANCE (KM)
                    TextField(LocalizedKey.formTotalDistance.localized(), text: $totalDistance)
                        .textFieldStyle()
                        .focused($focusedField, equals: .totalDistance)
                    
                    // DAYS
                    TextField(LocalizedKey.formDays.localized(), text: $days)
                        .textFieldStyle()
                        .focused($focusedField, equals: .days)
                    
                    // SUBMIT BUTTON
                    submitButton
                    
                    // ACHIEVEMENT BUTTON
                    achievementButton
                    
                    // ACHIEVEMENT PREVIEW CARD
                    achievementPreviewCard
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                
            }
        }
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            submitData()
        }) {
            HStack {
                if stepViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(stepViewModel.isLoading ? LocalizedKey.saving.localized() : LocalizedKey.submit.localized())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(stepViewModel.isLoading ? Color.blue.opacity(0.6) : Color.blue)
            .cornerRadius(10)
        }
        .disabled(stepViewModel.isLoading)
    }
    
    // MARK: - Achievement Button
    private var achievementButton: some View {
        NavigationLink(destination: AchievementsView()) {
            HStack(spacing: 10) {
                Text(LocalizedKey.achievements.localized())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "43A047"))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Achievement Preview Card
    private var achievementPreviewCard: some View {
        let progress = achievementViewModel.getDailyStepsProgress()
        
        return VStack(alignment: .leading, spacing: 12) {
            // Header Section
            HStack {
                // Trophy Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFF9E6"))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "FFB800"))
                }
                
                // Achievements Title
                Text(LocalizedKey.achievements.localized())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // View All Link
                NavigationLink(destination: AchievementsView()) {
                    HStack(spacing: 4) {
                        Text(LocalizedKey.viewAll.localized())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Achievement Progress Section
            if !progress.isAllCompleted {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Achievement Name
                        Text(LocalizedKey.localizeAchievementTitle(progress.nextTitle))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(Color(hex: "4CAF50"))
                                    .frame(width: geometry.size.width * CGFloat(progress.progress), height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        // Remaining Steps Text - Show exact amount
                        let exactRemaining = Int(progress.remainingValue)
                        Text(String(format: LocalizedKey.stepsLeft.localized(), "\(exactRemaining)"))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Badge Image (Right Side) - Always show unlocked version
                    let badgeImageName = getBadgeImageName(for: progress.nextTargetValue, isUnlocked: true)
                    
                    Group {
                        if UIImage(named: badgeImageName) != nil {
                            Image(badgeImageName)
                                .resizable()
                                .renderingMode(.original)
                                .interpolation(.high)
                                .antialiased(true)
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        } else {
                            // Fallback if image not found
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "4CAF50"))
                            }
                        }
                    }
                }
            } else {
                Text(progress.remainingText)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    // MARK: - Helper to Format Target Value
    private func formatTargetValue(_ value: Double) -> String {
        let intValue = Int(value)
        if intValue >= 1000 {
            return "\(intValue / 1000)k"
        }
        return "\(intValue)"
    }
    
    // MARK: - Helper to Get Badge Image Name
    private func getBadgeImageName(for targetValue: Double, isUnlocked: Bool) -> String {
        let intValue = Int(targetValue)
        
        // Find matching achievement from CoreDataManager
        if let achievement = CoreDataManager.dailyStepsAchievements.first(where: { $0.threshold == intValue }) {
            // Return the correct image name: badge3kUnlock, badge7kUnlock, etc.
            return isUnlocked ? achievement.unlockImage : achievement.lockImage
        }
        
        // Fallback: Generate image name based on value
        // Format: badge3kUnlock, badge7kUnlock, badge10kUnlock, etc.
        let valueString: String
        if intValue >= 1000 {
            valueString = "\(intValue / 1000)k"
        } else {
            valueString = "\(intValue)"
        }
        
        // Return in format: badge3kUnlock or badge3kLock
        return isUnlocked ? "badge\(valueString)Unlock" : "badge\(valueString)Lock"
    }
    
    // MARK: - Stats Summary Card
    private var statsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedKey.currentStats.localized())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            HStack(spacing: 20) {
                StatItemView(
                    title: LocalizedKey.totalSteps.localized(),
                    value: stepViewModel.formatSteps(Int(stepViewModel.totalSteps))
                )
                
                StatItemView(
                    title: LocalizedKey.distance.localized(),
                    value: String(format: "%.1f km", stepViewModel.totalDistance)
                )
                
                StatItemView(
                    title: LocalizedKey.days.localized(),
                    value: "\(stepViewModel.totalDays)"
                )
                
                StatItemView(
                    title: LocalizedKey.level.localized(),
                    value: "L\(stepViewModel.currentLevel)"
                )
            }
            
            if stepViewModel.currentLevel < 20 && stepViewModel.totalSteps > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: LocalizedKey.stepsToLevel.localized(), stepViewModel.formatSteps(stepViewModel.stepsToNextLevel), stepViewModel.nextLevel))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(stepViewModel.levelProgress), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    // MARK: - Submit Data (ADD-ONLY Logic)
    private func submitData() {
        let dailyStepsValue: Int? = parsePositiveInt(dailySteps)
        let extraStepsValue: Int? = parsePositiveInt(lifetimeSteps)
        let extraDistanceValue: Double? = parsePositiveDouble(totalDistance)
        let extraDaysValue: Int? = parsePositiveInt(days)
        
        let hasValidInput = dailyStepsValue != nil ||
                           extraStepsValue != nil ||
                           extraDistanceValue != nil ||
                           extraDaysValue != nil
        
        guard hasValidInput else {
            alertMessage = LocalizedKey.enterPositiveValue.localized()
            showErrorAlert = true
            return
        }
        
        stepViewModel.addUserInput(
            dailySteps: dailyStepsValue,
            extraSteps: extraStepsValue,
            extraDistance: extraDistanceValue,
            extraDays: extraDaysValue
        )
        
        dailySteps = ""
        lifetimeSteps = ""
        totalDistance = ""
        days = ""
    }
    
    // MARK: - Validation Helpers
    private func parsePositiveInt(_ string: String) -> Int? {
        guard !string.isEmpty else { return nil }
        guard let value = Int(string), value > 0 else { return nil }
        return value
    }
    
    private func parsePositiveDouble(_ string: String) -> Double? {
        guard !string.isEmpty else { return nil }
        guard let value = Double(string), value > 0 else { return nil }
        return value
    }
}

// MARK: - Stat Item View
struct StatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

extension View {
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .font(.system(size: 16))
            .keyboardType(.decimalPad)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PedometerPersistenceController.preview.container.viewContext)
}
