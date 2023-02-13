import SwiftUI
import SwiftUINavigation
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature


@main
@MainActor
struct App: SwiftUI.App {

    @StateObject private var model = AppModel(
        selectedTab: .standups,
        standupsTabModel: .init(
            standupsListModel: .init()
        ),
        profileTabModel: .init()
    )

    var body: some Scene {
        WindowGroup {
            TabView(selection: $model.selectedTab) {
                StandupsTabView(model: model.standupsTabModel)
                    .tag(AppModel.Tab.standups)
                    .tabItem { Label("Standups", systemImage: "list.bullet") }

                ProfileTabView(model: model.profileTabModel)
                    .tag(AppModel.Tab.profile)
                    .tabItem { Label("Profile", systemImage: "person.fill") }
            }
        }
    }
}
