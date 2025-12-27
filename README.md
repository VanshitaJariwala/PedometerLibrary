# PedometerLibrary

A SwiftUI library for step tracking with achievements and level progression.

## Features

- ✅ Step tracking
- ✅ Achievement system
- ✅ Level progression
- ✅ Core Data persistence
- ✅ Beautiful UI components

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/VanshitaJariwala/PedometerLibrary.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies...
2. Enter: `https://github.com/VanshitaJariwala/PedometerLibrary.git`
3. Select version: `1.0.0` or later

## Usage

```swift
import SwiftUI
import CoreData
import PedometerLibrary

@main
struct MyApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Initialize library
        PedometerLibrary.initialize(context: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            // Use library views
            PedometerLibrary.makeHomeView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## License

MIT License

