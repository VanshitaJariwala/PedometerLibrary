# PedometerLibrary - Usage Guide (Gujarati/English)

## ✅ હા, તમે આ package ને બીજા project માં use કરી શકો છો!

## 📦 Installation (સ્થાપન)

### Method 1: Xcode માં (સૌથી સરળ)

1. તમારા project માં જાઓ
2. **File → Add Package Dependencies...**
3. URL enter કરો: `https://github.com/VanshitaJariwala/PedometerLibrary.git`
4. Version select કરો: `1.0.0` અથવા latest
5. **Add Package** ક્લિક કરો

### Method 2: Package.swift માં

```swift
dependencies: [
    .package(url: "https://github.com/VanshitaJariwala/PedometerLibrary.git", from: "1.0.0")
]
```

## 🚀 Quick Start (ઝડપી શરૂઆત)

### Step 1: Import કરો

```swift
import SwiftUI
import CoreData
import PedometerLibrary
```

### Step 2: App માં Initialize કરો

```swift
@main
struct MyApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Library initialize કરો
        PedometerLibrary.initialize(
            context: persistenceController.container.viewContext
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

### Step 3: Views Use કરો

```swift
import SwiftUI
import PedometerLibrary

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            // Home View (Step tracking + Achievements)
            PedometerLibrary.makeHomeView(context: viewContext)
        }
    }
}
```

## 📱 Available Views (ઉપલબ્ધ Views)

### 1. Home View (મુખ્ય પાનું)
Step tracking અને achievement preview:
```swift
PedometerLibrary.makeHomeView(context: viewContext)
```

### 2. Achievements View (બધા achievements)
```swift
PedometerLibrary.makeAchievementsView(context: viewContext)
```

### 3. Daily Steps View
```swift
PedometerLibrary.makeDailyStepsView(context: viewContext)
```

### 4. Total Days View
```swift
PedometerLibrary.makeTotalDaysView(context: viewContext)
```

### 5. Total Distance View
```swift
PedometerLibrary.makeTotalDistanceView(context: viewContext)
```

### 6. Level View
```swift
PedometerLibrary.makeLevelView(context: viewContext)
```

## 🔧 ViewModels Use કરવા માટે

### StepTrackingViewModel
```swift
let stepViewModel = PedometerLibrary.makeStepTrackingViewModel(context: viewContext)

// Steps add કરો
stepViewModel.addUserInput(
    dailySteps: 5000,
    extraSteps: 10000,
    extraDistance: 5.5,
    extraDays: 1
)

// Data refresh કરો
stepViewModel.refresh()
```

### AchievementViewModel
```swift
let achievementViewModel = PedometerLibrary.makeAchievementViewModel(context: viewContext)

// Progress get કરો
let progress = achievementViewModel.getDailyStepsProgress()
print("Progress: \(progress.progress)")
print("Remaining: \(progress.remainingText)")

// Data refresh કરો
achievementViewModel.refresh()
```

## 📋 Complete Example (સંપૂર્ણ ઉદાહરણ)

```swift
import SwiftUI
import CoreData
import PedometerLibrary

@main
struct MyPedometerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Initialize library
        PedometerLibrary.initialize(
            context: persistenceController.container.viewContext
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    // Home View
                    PedometerLibrary.makeHomeView(
                        context: persistenceController.container.viewContext
                    )
                    
                    // Navigation to Achievements
                    NavigationLink("View All Achievements") {
                        PedometerLibrary.makeAchievementsView(
                            context: persistenceController.container.viewContext
                        )
                    }
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

## 🎯 Features (વિશેષતાઓ)

- ✅ Step tracking (પગલાં ટ્રેકિંગ)
- ✅ Achievement system (પ્રાપ્તિઓ સિસ્ટમ)
- ✅ Level progression (સ્તર પ્રગતિ)
- ✅ Core Data persistence (ડેટા સંગ્રહ)
- ✅ Beautiful UI components (સુંદર UI ઘટકો)
- ✅ Localization support (ભાષા સમર્થન)

## ⚙️ Requirements (જરૂરિયાતો)

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## 📝 Notes (નોંધો)

1. **Core Data Context**: Library Core Data use કરે છે, તેથી તમારા app માં Core Data setup કરવું જરૂરી છે.

2. **Initialization**: App launch પર `PedometerLibrary.initialize()` call કરવું જરૂરી છે.

3. **Environment**: Views માં `.environment(\.managedObjectContext, context)` pass કરવું જરૂરી છે.

4. **GitHub Repository**: Package GitHub પર publish થયેલું હોવું જોઈએ અથવા local path થી add કરી શકાય છે.

## 🔗 GitHub પર Publish કરવા માટે

1. Repository GitHub પર push કરો
2. Tag create કરો: `git tag 1.0.0`
3. Tag push કરો: `git push origin 1.0.0`
4. હવે package URL use કરી શકાય છે!

## 💡 Tips (સૂચનાઓ)

- Library ને local development માટે use કરવા માટે, Xcode માં local path add કરો
- Customization માટે ViewModels directly use કરી શકો છો
- All public APIs `PedometerLibrary` struct માં available છે

---

**Happy Coding! 🎉**

