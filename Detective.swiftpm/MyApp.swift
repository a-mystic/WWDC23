import SwiftUI

@main
struct MyApp: App {
    @StateObject private var detective = Detective()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(detective)
        }
    }
}
