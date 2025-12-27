//
//  AchievementNotificationView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 08/12/25.
//

import SwiftUI
import UIKit
import ConfettiSwiftUI

public struct AchievementNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var confettiCounter: Int = 0
    
    let level: Int?
    let levelName: String?
    let stepRequirement: Int?
    
    let achievementType: AchievementType?
    let badgeImageName: String?
    let titleText: String?
    let descriptionText: String?
    let achievementValue: Double?
    
    public init(level: Int, levelName: String, stepRequirement: Int) {
        self.level = level
        self.levelName = levelName
        self.stepRequirement = stepRequirement
        self.achievementType = .level
        self.badgeImageName = "LV_\(level)"
        self.titleText = levelName
        self.descriptionText = String(format: LocalizedKey.completedSteps.localized(), Self.formatStepsStatic(stepRequirement))
        self.achievementValue = Double(stepRequirement)
    }
    
    public init(
        achievementType: AchievementType,
        badgeImageName: String,
        titleText: String,
        descriptionText: String,
        achievementValue: Double
    ) {
        self.level = nil
        self.levelName = nil
        self.stepRequirement = nil
        self.achievementType = achievementType
        self.badgeImageName = badgeImageName
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.achievementValue = achievementValue
    }
    
    public init(data: AchievementNotificationData) {
        self.level = nil
        self.levelName = nil
        self.stepRequirement = nil
        self.achievementType = data.type
        self.badgeImageName = data.badgeImageName
        self.titleText = data.titleText
        self.descriptionText = data.descriptionText
        self.achievementValue = data.achievementValue
    }
    
    private var gradientStartColor: Color {
        guard let achievementType = achievementType else {
            return Color(hex: "9E28EF")
        }
        
        switch achievementType {
        case .level:
            return Color(hex: "088997")
        case .dailySteps:
            return Color(hex: "43A047")
        case .totalDays:
            return Color(hex: "9E28EF")
        case .totalDistance:
            return Color(hex: "0876FA")
        }
    }
    
    private var confettiColors: [Color] {
        guard let achievementType = achievementType else {
            return [
                Color(hex: "9E28EF"),
                Color(hex: "BA5CFF"),
                Color(hex: "D18FFF"),
                Color.white
            ]
        }
        
        switch achievementType {
        case .level:
            return [
                Color(hex: "088997"),
                Color(hex: "0AA5B5"),
                Color(hex: "2BC4D3"),
                Color(hex: "4DE3F0"),
                Color.white
            ]
        case .dailySteps:
            return [
                Color(hex: "43A047"),
                Color(hex: "66BB6A"),
                Color(hex: "81C784"),
                Color(hex: "A5D6A7"),
                Color.white
            ]
        case .totalDays:
            return [
                Color(hex: "9E28EF"),
                Color(hex: "BA5CFF"),
                Color(hex: "D18FFF"),
                Color(hex: "E8B2FF"),
                Color.white
            ]
        case .totalDistance:
            return [
                Color(hex: "0876FA"),
                Color(hex: "3A8FFB"),
                Color(hex: "6CA8FC"),
                Color(hex: "9EC1FD"),
                Color.white
            ]
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        gradientStartColor,
                        Color(hex: "FFFFFF"),
                        Color(hex: "FFFFFF"),
                        Color(hex: "FFFFFF")
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            shareAchievement()
                        }) {
                            Image("share")
                                .resizable()
                                .renderingMode(.original)
                                .interpolation(.high)
                                .antialiased(true)
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer()
//                        .frame(height: geometry.size.height * 0.02)
                    
                    ZStack(alignment: .center) {
                        Color.clear
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                            .offset(y: geometry.size.height * 0.30) // Move confetti down by 12% of screen height
                            .confettiCannon(
                                trigger: $confettiCounter,
                                num: 10,
                                colors: confettiColors,
                                confettiSize: 15.0,
                                rainHeight: 450,
                                fadesOut: true,
                                opacity: 1.0,
                                openingAngle: .degrees(60),
                                closingAngle: .degrees(120),
                                radius: 400,
                                repetitions: 50,
                                repetitionInterval: 0.1
                            )
                            .allowsHitTesting(false)
                        
                        let imageName = badgeImageName ?? (level != nil ? "LV_\(level!)" : "LV_1")
                        let badgeSize = min(geometry.size.width * 0.6, geometry.size.height * 0.35, 300)
                        
                        if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .renderingMode(.original)
                                .interpolation(.high)
                                .antialiased(true)
                                .scaledToFit()
                                .frame(width: badgeSize, height: badgeSize)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.85, green: 0.85, blue: 0.9),
                                                Color(red: 0.7, green: 0.7, blue: 0.75),
                                                Color(red: 0.85, green: 0.85, blue: 0.9)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: badgeSize * 0.9, height: badgeSize * 0.9)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                    .frame(width: badgeSize * 0.85, height: badgeSize * 0.85)
                                
                                if let level = level {
                                    VStack(spacing: 4) {
                                        Text("L\(level)")
                                            .font(.system(size: badgeSize * 0.24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: badgeSize * 0.1, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: badgeSize * 0.24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: badgeSize, height: badgeSize)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    
                    Spacer()
//                        .frame(height: geometry.size.height * 0.08)
                    
                    VStack(spacing: 12) {
                        if let titleText = titleText {
                            Text(LocalizedKey.localizeAchievementTitle(titleText))
                                .font(.system(size: min(geometry.size.width * 0.055, 22), weight: .bold))
                                .foregroundColor(.black)
                                .padding(.bottom, 4)
                        } else if let levelName = levelName {
                            Text(LocalizedKey.localizeLevelName(levelName))
                                .font(.system(size: min(geometry.size.width * 0.055, 22), weight: .bold))
                                .foregroundColor(.black)
                                .padding(.bottom, 4)
                        }
                        
                        Text("-: \(LocalizedKey.formAchievement.localized()): -")
                            .font(.system(size: min(geometry.size.width * 0.042, 16), weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                        
                        Text(LocalizedKey.congratulations.localized())
                            .font(.system(size: min(geometry.size.width * 0.085, 32), weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(LocalizedKey.reachedNewBadge.localized())
                            .font(.system(size: min(geometry.size.width * 0.042, 16)))
                            .foregroundColor(.gray)
                        
                        if let descriptionText = descriptionText {
                            Text(descriptionText)
                                .font(.system(size: min(geometry.size.width * 0.042, 16)))
                                .foregroundColor(.gray)
                        } else if let stepRequirement = stepRequirement {
                            Text(String(format: LocalizedKey.completedSteps.localized(), formatSteps(stepRequirement)))
                                .font(.system(size: min(geometry.size.width * 0.042, 16)))
                                .foregroundColor(.gray)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top, geometry.size.width * 0.13)
                    
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text(LocalizedKey.continue.localized())
                            .font(.system(size: min(geometry.size.width * 0.048, 18), weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "43A047"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top,geometry.size.width * 0.05)
                    .padding(.bottom, geometry.size.height * 0.99)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            confettiCounter += 1
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
    
    func shareAchievement() {
        if let image = captureAchievementImage() {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootVC.present(activityVC, animated: true)
            }
        } else {
            let shareText: String
            if let level = level, let levelName = levelName, let stepRequirement = stepRequirement {
                shareText = String(format: LocalizedKey.shareLevelAchievement.localized(), level, levelName, formatSteps(stepRequirement))
            } else if let titleText = titleText, let descriptionText = descriptionText {
                shareText = String(format: LocalizedKey.shareAchievementGeneric.localized(), titleText, descriptionText)
            } else {
                shareText = LocalizedKey.shareAchievementCompleted.localized()
            }
            
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
    
    private func captureAchievementImage() -> UIImage? {
        let achievementContentView = achievementContent
        
        let hostingController = UIHostingController(rootView: achievementContentView)
        hostingController.view.backgroundColor = .clear
        
        let targetSize = CGSize(width: 1080, height: 1920)
        hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
        
        let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
        window.rootViewController = hostingController
        window.isHidden = false
        window.makeKeyAndVisible()
        
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { context in
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
        
        window.isHidden = true
        
        return image
    }
    
    private var achievementContent: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    gradientStartColor,
                    Color(hex: "FFFFFF"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 150)
                
                VStack(spacing: 0) {
                    let imageName = badgeImageName ?? (level != nil ? "LV_\(level!)" : "LV_1")
                    
                    if UIImage(named: imageName) != nil {
                        Image(imageName)
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 600, height: 600)
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    } else {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.85, green: 0.85, blue: 0.9),
                                            Color(red: 0.7, green: 0.7, blue: 0.75),
                                            Color(red: 0.85, green: 0.85, blue: 0.9)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 540, height: 540)
                                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                            
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 6)
                                .frame(width: 510, height: 510)
                            
                            if let level = level {
                                VStack(spacing: 8) {
                                    Text("L\(level)")
                                        .font(.system(size: 144, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 60, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            } else {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 144, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 24) {
                    if let titleText = titleText {
                        Text(LocalizedKey.localizeAchievementTitle(titleText))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                    } else if let levelName = levelName {
                        Text(LocalizedKey.localizeLevelName(levelName))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                    }
                    
                    Text("-: \(LocalizedKey.formAchievement.localized()): -")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                    
                    Text(LocalizedKey.congratulations.localized())
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.black)
                    
                    if let titleText = titleText {
                        Text(String(format: LocalizedKey.reachedBadge.localized(), titleText))
                            .font(.system(size: 42))
                            .foregroundColor(.gray)
                    } else if let levelName = levelName {
                        Text(String(format: LocalizedKey.reachedBadge.localized(), levelName))
                            .font(.system(size: 42))
                            .foregroundColor(.gray)
                    } else {
                        Text(LocalizedKey.reachedNewBadge.localized())
                            .font(.system(size: 42))
                            .foregroundColor(.gray)
                    }
                    
                    if let descriptionText = descriptionText {
                        Text(descriptionText)
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    } else if let stepRequirement = stepRequirement {
                        Text(String(format: LocalizedKey.completedSteps.localized(), formatSteps(stepRequirement)))
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 50)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                
                Spacer()
                    .frame(height: 150)
            }
        }
        .frame(width: 1080, height: 1920)
    }
    
    static func formatStepsStatic(_ steps: Int) -> String {
        if steps >= 1000000 {
            return String(format: "%.1fM", Double(steps) / 1000000.0)
        } else if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
}

#Preview {
    AchievementNotificationView(level: 2, levelName: "10k Steps", stepRequirement: 10000)
}
