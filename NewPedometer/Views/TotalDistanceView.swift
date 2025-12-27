//
//  TotalDistanceView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData

public struct TotalDistanceView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var achievementViewModel: AchievementViewModel
    
    @State private var showLockedAlert = false
    @State private var lockedAlertMessage = ""
    
    let distanceAchievements: [(Double, String, String, String, String)] = [
        (3.0, "3", "Mini Trekker", "miles3Unlock", "miles3Lock"),
        (5.0, "5", "Path Seeker", "miles5Unlock", "miles5Lock"),
        (12.0, "12", "Journey Maker", "miles12Unlock", "miles12Lock"),
        (26.0, "26", "Marathoner", "miles26Unlock", "miles26Lock"),
        (60.0, "60", "Road Challenger", "miles60Unlock", "miles60Lock"),
        (135.0, "135", "City Connector", "miles135Unlock", "miles135Lock"),
        (280.0, "280", "Continent Strider", "miles280Unlock", "miles280Lock"),
        (500.0, "500", "Desert Voyager", "miles500Unlock", "miles500Lock"),
        (1200.0, "1200", "Country Crawler", "miles1200Unlock", "miles1200Lock"),
        (3950.0, "3950", "World Wanderer", "miles3950Unlock", "miles3950Lock")
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
                            ForEach(distanceAchievements, id: \.2) { achievement in
                                let isUnlocked = achievementViewModel.totalDistance >= achievement.0
                                
                                if isUnlocked {
                                    NavigationLink(destination: AchievementNotificationView(
                                        achievementType: .totalDistance,
                                        badgeImageName: achievement.3,
                                        titleText: achievement.2,
                                        descriptionText: String(format: LocalizedKey.walkedDistance.localized(), achievement.0),
                                        achievementValue: achievement.0
                                    )) {
                                        DistanceRowView(
                                            achievement: achievement,
                                            isUnlocked: isUnlocked
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    Button(action: {
                                        let remaining = achievement.0 - achievementViewModel.totalDistance
                                        lockedAlertMessage = String(format: LocalizedKey.lockedMessageDistance.localized(), remaining, achievement.2)
                                        showLockedAlert = true
                                    }) {
                                        DistanceRowView(
                                            achievement: achievement,
                                            isUnlocked: isUnlocked
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
        let unlockedCount = distanceAchievements.filter { achievementViewModel.totalDistance >= $0.0 }.count
        let shareText = String(format: LocalizedKey.shareTotalDistance.localized(), achievementViewModel.totalDistance, unlockedCount, distanceAchievements.count)
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        let currentKm = achievementViewModel.totalDistance
        let nextAchievement = distanceAchievements.first { currentKm < $0.0 }
        let currentTarget = nextAchievement ?? distanceAchievements.last
        let targetKm = currentTarget?.0 ?? 0
        let remaining = max(0, targetKm - currentKm)
        let progress = targetKm > 0 ? min(1.0, currentKm / targetKm) : 0.0
        let isUnlocked = currentKm >= (currentTarget?.0 ?? 0)
        let headerImageName = isUnlocked ? (currentTarget?.3 ?? "miles3Unlock") : (currentTarget?.4 ?? "miles3Lock")
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
                    Text(String(format: LocalizedKey.moreKmToAchieve.localized(), remaining))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedKey.localizeAchievementTitle(title))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                } else {
                    Text(LocalizedKey.allDistanceCompleted.localized())
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

// MARK: - Distance Row
struct DistanceRowView: View {
    let achievement: (Double, String, String, String, String)
    let isUnlocked: Bool
    
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
    TotalDistanceView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
