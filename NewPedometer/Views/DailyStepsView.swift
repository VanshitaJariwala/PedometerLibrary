//
//  DailyStepsView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData

public struct DailyStepsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var achievementViewModel: AchievementViewModel
    
    @State private var showLockedAlert = false
    @State private var lockedAlertMessage = ""
    
    let achievements: [(Double, String, String, String, String)] = [
        (3000, "3k", "First Footprint", "badge3kUnlock", "badge3kLock"),
        (7000, "7k", "Step Warrior", "badge7kUnlock", "badge7kLock"),
        (10000, "10k", "Pace Master", "badge10kUnlock", "badge10kLock"),
        (14000, "14k", "Stride Champion", "badge14kUnlock", "badge14kLock"),
        (20000, "20k", "Trail Blazer", "badge20kUnlock", "badge20kLock"),
        (30000, "30k", "Step Titan", "badge30kUnlock", "badge30kLock"),
        (40000, "40k", "Endurance Hero", "badge40kUnlock", "badge40kLock"),
        (60000, "60k", "Legend Walker", "badge60kUnlock", "badge60kLock")
    ]
    
    public init() {
        let context = PersistenceController.shared.container.viewContext
        _achievementViewModel = StateObject(wrappedValue: AchievementViewModel(context: context))
    }
    
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
                        
                        // MARK: - LIST CARD
                        VStack(spacing: 0) {
                            ForEach(achievements, id: \.2) { achievement in
                                let isUnlocked = achievementViewModel.dailySteps >= achievement.0
                                let unlockedDate = achievementViewModel.dailyStepsAchievements.first { $0.targetValue == achievement.0 }?.unlockedDate
                                
                                if isUnlocked {
                                    NavigationLink(destination: AchievementNotificationView(
                                        achievementType: .dailySteps,
                                        badgeImageName: achievement.3,
                                        titleText: achievement.2,
                                        descriptionText: String(format: LocalizedKey.completedStepsToday.localized(), formatSteps(Int(achievement.0))),
                                        achievementValue: achievement.0
                                    )) {
                                        DailyStepRow(
                                            achievement: achievement,
                                            isUnlocked: isUnlocked,
                                            unlockedDate: unlockedDate
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    Button(action: {
                                        let remaining = achievement.0 - achievementViewModel.dailySteps
                                        lockedAlertMessage = String(format: LocalizedKey.lockedMessageSteps.localized(), formatSteps(Int(remaining)), achievement.2)
                                        showLockedAlert = true
                                    }) {
                                        DailyStepRow(
                                            achievement: achievement,
                                            isUnlocked: isUnlocked,
                                            unlockedDate: nil
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
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
        .navigationTitle(LocalizedKey.dailySteps.localized())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
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
        }
        .onAppear {
            achievementViewModel.refresh()
        }
        .alert(LocalizedKey.lockedAchievement.localized(), isPresented: $showLockedAlert) {
            Button(LocalizedKey.ok.localized(), role: .cancel) { }
        } message: {
            Text(lockedAlertMessage)
        }
    }
    
    func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
    
    func shareAchievements() {
        let unlockedCount = achievements.filter { achievementViewModel.dailySteps >= $0.0 }.count
        let shareText = String(format: LocalizedKey.shareDailySteps.localized(), unlockedCount, achievements.count, formatSteps(Int(achievementViewModel.dailySteps)))
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        let nextAchievement = achievements.first { achievementViewModel.dailySteps < $0.0 }
        let currentTarget = nextAchievement ?? achievements.last
        let targetSteps = currentTarget?.0 ?? 0
        let remaining = max(0, targetSteps - achievementViewModel.dailySteps)
        let progress = targetSteps > 0 ? min(1.0, achievementViewModel.dailySteps / targetSteps) : 0.0
        let isUnlocked = achievementViewModel.dailySteps >= targetSteps
        let headerImageName = isUnlocked ? (currentTarget?.3 ?? "badge3kUnlock") : (currentTarget?.4 ?? "badge3kLock")
        let title = currentTarget?.2 ?? ""
        
        return VStack(spacing: 16) {
            Image(headerImageName)
                .resizable()
                .renderingMode(.original)
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: 140, height: 140)
                .padding(.top, 12)
            
            VStack(spacing: 4) {
                if remaining > 0 {
                    Text(String(format: LocalizedKey.moreStepsToWin.localized(), formatSteps(Int(remaining))))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedKey.localizeAchievementTitle(title))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                } else {
                    Text(LocalizedKey.allDailyCompleted.localized())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color(red: 0.2, green: 0.8, blue: 0.3))
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

// MARK: - Daily Step Row
struct DailyStepRow: View {
    let achievement: (Double, String, String, String, String)
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            let badgeImageName = isUnlocked ? achievement.3 : achievement.4
            if UIImage(named: badgeImageName) != nil {
                Image(badgeImageName)
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            } else {
                HexagonShape()
                    .fill(isUnlocked ? Color(red: 0.2, green: 0.8, blue: 0.3) : Color(red: 0.9, green: 0.9, blue: 0.9))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedKey.localizeAchievementTitle(achievement.2))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                if isUnlocked, let date = unlockedDate {
                    Text(dateFormatter.string(from: date))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(isUnlocked ? "unlock" : "lock")
                .foregroundColor(isUnlocked ? .green : .gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}

#Preview {
    DailyStepsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
