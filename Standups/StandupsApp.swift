import SwiftUI
import Models

import Navigation
import StandupsListFeature
import OtherFeature

@main
@MainActor
struct StandupsApp: App {

    @StateObject private var model = StandupsAppModel()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $model.selectedTab) {
                NavigationView {
                    StandupsListView(model: model.standupsListModel)
                }
                .tabItem { Label("Standups", systemImage: "circle.fill") }
                .tag(AppTab.standups)

                NavigationView {
                    OtherView(model: model.otherModel)
                }
                .tabItem { Label("Other", systemImage: "rectangle.fill") }
                .tag(AppTab.other)
            }
        }
    }
}
