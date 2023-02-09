import SwiftUI
import SwiftUINavigation
import SwiftUINavigationBackport
import Models

import StandupsListFeature
import StandupDetailFeature
import OtherFeature

@main
@MainActor
struct StandupsApp: App {

    @StateObject private var model = StandupsListModel()

    var body: some Scene {
        WindowGroup {
            //            TabView(selection: $model.selectedTab) {
            NavigationView {
                StandupsListView(model: model)
                    .navigationDestination(
                        unwrapping: $model.destination,
                        case: /StandupsListModel.Destination.detail
                    ) { $detailModel in
                        StandupDetailView(model: detailModel)
                    }
                    .sheet(
                        unwrapping: $model.destination,
                        case: /StandupsListModel.Destination.add
                    ) { $model in
                        NavigationView {
                            EditStandupView(model: model)
                                .navigationTitle("New standup")
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Dismiss") { self.model.dismissAddStandupButtonTapped() }
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Add") { self.model.confirmAddStandupButtonTapped() }
                                    }
                                }
                        }
                    }
            }

            //                .tabItem { Label("Standups", systemImage: "circle.fill") }
            //                .tag(AppTab.standups)
            //
            //                NavigationView {
            //                    OtherView(model: model.otherModel)
            //                }
            //                .tabItem { Label("Other", systemImage: "rectangle.fill") }
            //                .tag(AppTab.other)
        }
    }
}
