//
//  TotalDaysView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData

public struct TotalDaysView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var achievementViewModel: AchievementViewModel
    
    @State private var showLockedAlert = false
    @State private var lockedAlertMessage = ""
    
    let dayAchievements: [(Int, String, String, String)] = [
        (7, "Weekly Walker", "days7Unlock", "days7Lock"),
        (14, "Two Week Trekker", "days14Unlock", "days14Lock"),
        (30, "Monthly Mover", "days30Unlock", "days30Lock"),
        (60, "Bi-Monthly Blazer", "days60Unlock", "days60Lock"),
        (100, "Century Stepper", "days100Unlock", "days100Lock"),
        (180, "Half Year Hero", "days180Unlock", "days180Lock"),
        (365, "Annual Achiever", "days365Unlock", "days365Lock"),
        (500, "Legendary Strider", "days500Unlock", "days500Lock"),
        (1000, "Millennium Walker", "days1000Unlock", "days1000Lock")
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
                            ForEach(Array(dayAchievements.enumerated()), id: \.offset) { index, achievement in
                                let threshold = achievement.0
                                let isUnlocked = Int(achievementViewModel.totalDays) >= threshold
                                
                                if isUnlocked {
                                    NavigationLink(destination: AchievementNotificationView(
                                        achievementType: .totalDays,
                                        badgeImageName: achievement.2,
                                        titleText: achievement.1,
                                        descriptionText: String(format: LocalizedKey.activeForDays.localized(), threshold),
                                        achievementValue: Double(threshold)
                                    )) {
                                        DayRowView(
                                            dayValue: threshold,
                                            title: achievement.1,
                                            isUnlocked: isUnlocked,
                                            unlockImageName: achievement.2,
                                            lockImageName: achievement.3,
                                            showDivider: index != dayAchievements.count - 1
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    Button(action: {
                                        let remaining = threshold - Int(achievementViewModel.totalDays)
                                        lockedAlertMessage = String(format: LocalizedKey.lockedMessageDays.localized(), remaining, achievement.1)
                                        showLockedAlert = true
                                    }) {
                                        DayRowView(
                                            dayValue: threshold,
                                            title: achievement.1,
                                            isUnlocked: isUnlocked,
                                            unlockImageName: achievement.2,
                                            lockImageName: achievement.3,
                                            showDivider: index != dayAchievements.count - 1
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
    
    func shareAchievements() {
        let unlockedCount = dayAchievements.filter { Int(achievementViewModel.totalDays) >= $0.0 }.count
        let shareText = String(format: LocalizedKey.shareTotalDays.localized(), Double(achievementViewModel.totalDays), unlockedCount, dayAchievements.count)
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        let currentDays = Int(achievementViewModel.totalDays)
        let nextAchievement = dayAchievements.first { currentDays < $0.0 }
        let currentTarget = nextAchievement ?? dayAchievements.last
        let targetDays = currentTarget?.0 ?? 0
        let remaining = max(0, targetDays - currentDays)
        let progress = targetDays > 0 ? min(1.0, Double(currentDays) / Double(targetDays)) : 0.0
        let isUnlocked = currentDays >= targetDays
        let headerImageName = isUnlocked ? (currentTarget?.2 ?? "days7Unlock") : (currentTarget?.3 ?? "days7Lock")
        let title = currentTarget?.1 ?? ""
        
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
                    Text(String(format: LocalizedKey.moreDaysToAchieve.localized(), remaining))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedKey.localizeAchievementTitle(title))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                } else {
                    Text(LocalizedKey.allDaysCompleted.localized())
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
                        .fill(Color.green)
                        .frame(width: geometry.size.width * CGFloat(progress),
                               height: 8)
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

// MARK: - Row View
struct DayRowView: View {
    let dayValue: Int
    let title: String
    let isUnlocked: Bool
    let unlockImageName: String
    let lockImageName: String
    let showDivider: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(isUnlocked ? unlockImageName : lockImageName)
                .resizable()
                .renderingMode(.original)
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedKey.localizeAchievementTitle(title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Image(isUnlocked ? "unlock" : "lock")
                .foregroundColor(isUnlocked ? .green : .gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(
            Group {
                if showDivider {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2))
                        .padding(.leading, 96)
                }
            },
            alignment: .bottom
        )
    }
}

#Preview {
    TotalDaysView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
