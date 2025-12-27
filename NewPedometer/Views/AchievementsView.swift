//
//  AchievementsView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import CoreData
import UIKit

enum AchievementLabelType {
    case steps
    case days
    case distance
}

public struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var achievementViewModel: AchievementViewModel
    
    @State private var lastKnownDate: Date = Date()
    
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
        let context = PersistenceController.shared.container.viewContext
        _achievementViewModel = StateObject(wrappedValue: AchievementViewModel(context: context))
    }

    public var body: some View {
        ZStack {
            Color(hex: "F3F5F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    // MARK: - LEVEL SECTION
                    NavigationLink(destination: LevelView()) {
                        levelSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .buttonStyle(PlainButtonStyle())
                    
                    // MARK: - DAILY STEPS
                    NavigationLink(destination: DailyStepsView()) {
                        let progress = achievementViewModel.getDailyStepsProgress()
                        achievementRow(
                            title: LocalizedKey.dailySteps.localized(),
                            achievements: [
                                (3000, "3k", "badge3kUnlock", "badge3kLock"),
                                (7000, "7k", "badge7kUnlock", "badge7kLock"),
                                (10000, "10k", "badge10kUnlock", "badge10kLock")
                            ],
                            currentValue: achievementViewModel.dailySteps,
                            progressValue: progress.progress,
                            remainingText: progress.remainingText,
                            isAllCompleted: progress.isAllCompleted,
                            labelType: .steps,
                            showSeparator: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // MARK: - TOTAL DAYS
                    NavigationLink(destination: TotalDaysView()) {
                        let progress = achievementViewModel.getTotalDaysProgress()
                        achievementRow(
                            title: LocalizedKey.totalDays.localized(),
                            achievements: [
                                (7, "7", "days7Unlock", "days7Lock"),
                                (14, "14", "days14Unlock", "days14Lock"),
                                (30, "30", "days30Unlock", "days30Lock")
                            ],
                            currentValue: Double(achievementViewModel.totalDays),
                            progressValue: progress.progress,
                            remainingText: progress.remainingText,
                            isAllCompleted: progress.isAllCompleted,
                            labelType: .days,
                            showSeparator: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // MARK: - TOTAL DISTANCE
                    NavigationLink(destination: TotalDistanceView()) {
                        let progress = achievementViewModel.getTotalDistanceProgress()
                        achievementRow(
                            title: LocalizedKey.totalDistance.localized(),
                            achievements: [
                                (3.0, "3", "miles3Unlock", "miles3Lock"),
                                (5.0, "5", "miles5Unlock", "miles5Lock"),
                                (12.0, "12", "miles12Unlock", "miles12Lock")
                            ],
                            currentValue: achievementViewModel.totalDistance,
                            progressValue: progress.progress,
                            remainingText: progress.remainingText,
                            isAllCompleted: progress.isAllCompleted,
                            labelType: .distance,
                            showSeparator: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle(LocalizedKey.achievements.localized())
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
            checkAndRefreshIfDateChanged()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkAndRefreshIfDateChanged()
        }
    }
    
    // MARK: - LEVEL SECTION VIEW
    private var levelSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: LocalizedKey.level.localized())
            
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    let levelImageName = "LV_\(achievementViewModel.currentLevel)"
                    if UIImage(named: levelImageName) != nil {
                        Image(levelImageName)
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                    } else {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.8, blue: 0.3),
                                            Color(red: 0.15, green: 0.75, blue: 0.25)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            VStack(spacing: 2) {
                                Text("L\(achievementViewModel.currentLevel)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                    Spacer()
                }
                
                let levelProgress = achievementViewModel.getLevelProgress()
                
                if !levelProgress.isAllCompleted {
                    VStack(spacing: 10) {
                        // Styled progress text
                        Text(levelProgress.remainingText)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        progressBar(progress: levelProgress.progress)
                    }
                } else {
                    Text(LocalizedKey.maximumLevelAchieved.localized())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
    
    // MARK: - Date Change Detection
    private func checkAndRefreshIfDateChanged() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDate = calendar.startOfDay(for: lastKnownDate)
        
        if today != lastDate {
            achievementViewModel.refresh()
            lastKnownDate = Date()
        } else {
            achievementViewModel.refresh()
        }
    }

    // MARK: - SECTION HEADER
    func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(LocalizedKey.more.localized())
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.3))
                .font(.system(size: 14, weight: .medium))
        }
    }
    
    // MARK: - PROGRESS BAR
    func progressBar(progress: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 10)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.8, blue: 0.3),
                                Color(red: 0.15, green: 0.75, blue: 0.25)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat(progress),
                        height: 10
                    )
            }
        }
        .frame(height: 10)
    }

    // MARK: - ACHIEVEMENT ROW
    func achievementRow(
        title: String,
        achievements: [(Double, String, String, String)],
        currentValue: Double,
        progressValue: Double,
        remainingText: String,
        isAllCompleted: Bool,
        labelType: AchievementLabelType,
        showSeparator: Bool = true
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: title)
            
            HStack {
                ForEach(achievements, id: \.1) { achievement in
                    Spacer()
                    let isUnlocked = currentValue >= achievement.0
                    let imageName = isUnlocked ? achievement.2 : achievement.3
                    
                    if UIImage(named: imageName) != nil {
                        Image(imageName)
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(isUnlocked ? Color(red: 0.2, green: 0.8, blue: 0.3) : .gray)
                            .frame(width: 80, height: 80)
                    }
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                progressBar(progress: progressValue)
                
                Text(remainingText)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            
            if showSeparator {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Hexagon Shape
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat.pi / 3 * CGFloat(i) - CGFloat.pi / 6
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationView {
        AchievementsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
