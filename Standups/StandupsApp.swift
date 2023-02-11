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
struct StandupsApp: App {

    @StateObject private var model = StandupsAppModel(
        path: [],
        standupsListModel: StandupsListModel()
    )

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: self.$model.path) {
                StandupsListView(model: model.standupsListModel)
                    .navigationDestination(for: RootPath.self) { path in
                        switch path {
                        case let .detail(standupDetailModel):
                            StandupDetailView(model: standupDetailModel)
                        case let .meeting(meeting, standup):
                            MeetingView(meeting: meeting, standup: standup)
                        case let .record(recordStandupModel):
                            RecordStandupView(model: recordStandupModel)
                        }
                    }
            }
            .sheet(unwrapping: $model.destination) { $destination in
                switch destination {
                case .add(let model),
                     .edit(let model):
                    NavigationStack {
                        EditStandupView(model: model)
                    }
                }
            }
        }
    }
}
