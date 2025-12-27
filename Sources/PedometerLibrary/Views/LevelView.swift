//
//  LevelView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData
#if canImport(UIKit)
import UIKit
#endif

struct LevelTuple: Identifiable {
    let id = UUID()
    let level: Int
    let stepRequirement: Int
    let levelName: String
}

public struct LevelView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var achievementViewModel: AchievementViewModel
    
    @State private var selectedLevel: LevelTuple? = nil
    @State private var navigateToAchievement = false
    
    @State private var showIncompletePopup = false
    @State private var incompleteLevelInfo: (Int, Int, String)? = nil
    
    let levels: [(Int, Int, String)] = [
        (1, 0, "Start"),
        (2, 10000, "10k Steps"),
        (3, 50000, "50k Steps"),
        (4, 100000, "100k Steps"),
        (5, 170000, "170k Steps"),
        (6, 220000, "220k Steps"),
        (7, 330000, "330k Steps"),
        (8, 440000, "440k Steps"),
        (9, 550000, "550k Steps"),
        (10, 660000, "660k Steps"),
        (11, 770000, "770k Steps"),
        (12, 880000, "880k Steps"),
        (13, 990000, "990k Steps"),
        (14, 1100000, "1100k Steps"),
        (15, 1200000, "1200k Steps"),
        (16, 1300000, "1300k Steps"),
        (17, 1400000, "1400k Steps"),
        (18, 1500000, "1500k Steps"),
        (19, 1600000, "1600k Steps"),
        (20, 2000000, "2000k Steps")
    ]
    
    public init() {
        let context = PedometerPersistenceController.shared.container.viewContext
        _achievementViewModel = StateObject(wrappedValue: AchievementViewModel(context: context))
    }
    
    #if canImport(UIKit)
    private func imageExists(_ name: String) -> Bool {
        return UIImage(named: name) != nil
    }
    #else
    private func imageExists(_ name: String) -> Bool {
        return true
    }
    #endif
    
    public var body: some View {
        ZStack {
            Color(hex: "F3F5F7")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - HEADER CARD
                headerCard
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        
                        // MARK: - LEVEL LIST CARD
                        VStack(spacing: 0) {
                            ForEach(levels, id: \.0) { level in
                                let isUnlocked = Int(achievementViewModel.lifetimeSteps) >= level.1
                                let isCurrentLevel = level.0 == achievementViewModel.currentLevel
                                
                                LevelRow(
                                    level: level.0,
                                    levelName: level.2,
                                    stepRequirement: level.1,
                                    isUnlocked: isUnlocked,
                                    isCurrentLevel: isCurrentLevel,
                                    achievedDate: isUnlocked ? Date() : nil,
                                    onTap: {
                                        if isUnlocked {
                                            selectedLevel = LevelTuple(level: level.0, stepRequirement: level.1, levelName: level.2)
                                            navigateToAchievement = true
                                        } else {
                                            incompleteLevelInfo = level
                                            showIncompletePopup = true
                                        }
                                    }
                                )
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        #endif
        .navigationTitle(LocalizedKey.level.localized())
        .onAppear {
            achievementViewModel.refresh()
        }
        .onChange(of: navigateToAchievement) { newValue in
            if !newValue {
                selectedLevel = nil
            }
        }
        .background(
            NavigationLink(
                destination: Group {
                    if let level = selectedLevel {
                        AchievementNotificationView(
                            level: level.level,
                            levelName: level.levelName,
                            stepRequirement: level.stepRequirement
                        )
                    }
                },
                isActive: $navigateToAchievement
            ) {
                EmptyView()
            }
        )
        .alert(LocalizedKey.lockedAchievement.localized(), isPresented: $showIncompletePopup) {
            Button(LocalizedKey.ok.localized(), role: .cancel) { }
        } message: {
            if let levelInfo = incompleteLevelInfo {
                let currentSteps = Int(achievementViewModel.lifetimeSteps)
                let remaining = max(0, levelInfo.1 - currentSteps)
                Text(String(format: LocalizedKey.lockedMessage.localized(), formatSteps(remaining), levelInfo.0, levelInfo.2))
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("back")
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            #endif
        }
    }
    
    func formatSteps(_ steps: Int) -> String {
        if steps >= 1000000 {
            return String(format: "%.1fM", Double(steps) / 1000000.0)
        } else if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
    
    #if canImport(UIKit)
    func shareLevel() {
        let shareText = String(format: LocalizedKey.shareLevelReached.localized(), achievementViewModel.currentLevel, formatSteps(Int(achievementViewModel.lifetimeSteps)))
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    #endif
    
    // MARK: - Header Card (top level badge + progress bar)
    private var headerCard: some View {
        let currentLevel = achievementViewModel.currentLevel
        let levelImageName = "LV_\(currentLevel)"
        
        let isMaxLevel = currentLevel >= 20
        let stepsNeeded = achievementViewModel.stepsToNextLevel
        let progress = achievementViewModel.levelProgress
        
        return VStack(spacing: 16) {
            if imageExists(levelImageName) {
                Image(levelImageName)
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.top, 12)
            } else {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.8, blue: 0.3))
                        .frame(width: 120, height: 120)
                    
                    Text("\(currentLevel)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 12)
            }
            
            VStack(spacing: 4) {
                if isMaxLevel {
                    Text(LocalizedKey.maximumLevelAchieved.localized())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    Text(String(format: LocalizedKey.moreStepsToLevel.localized(), formatSteps(stepsNeeded), currentLevel + 1))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedKey.localizeLevelName(levels[currentLevel - 1].2))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.green)
                        .frame(
                            width: geometry.size.width * CGFloat(progress),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
            .padding(.bottom, 12)
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct LevelRow: View {
    let level: Int
    let levelName: String
    let stepRequirement: Int
    let isUnlocked: Bool
    let isCurrentLevel: Bool
    let achievedDate: Date?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 16) {
                Image("LV_\(level)")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .opacity(isUnlocked ? 1.0 : 0.5)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedKey.localizeLevelName(levelName))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    if let date = achievedDate, isUnlocked {
                        Text(formatDate(date))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    } else {
                        Text(String(format: LocalizedKey.stepsRequired.localized(), formatSteps(stepRequirement)))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(isUnlocked ? "unlock" : "lock")
                    .font(.system(size: 18))
                    .foregroundColor(isUnlocked ? .green : .gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    func formatSteps(_ steps: Int) -> String {
        if steps >= 1000000 {
            return String(format: "%.1fM", Double(steps) / 1000000.0)
        } else if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
}

#Preview {
    LevelView()
        .environment(\.managedObjectContext, PedometerPersistenceController.preview.container.viewContext)
}
