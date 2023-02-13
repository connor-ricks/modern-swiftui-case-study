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
                    .navigationDestination(for: RootPathComponent.self) { path in
                        switch path {
                        case let .detail(standupDetailModel, standupDetailDestination):
                            StandupDetailView(model: standupDetailModel)
                                .sheet(
                                    unwrapping: .init(get: {
                                        standupDetailDestination
                                    }, set: { lol in
                                        model.update(destination: lol, in:path)
                                    }),
                                    case: /StandupDetailDestination.edit,
                                    content: { $editStandupModel in
                                        NavigationStack {
                                            EditStandupView(model: editStandupModel)
                                        }
                                    }
                                )
                        case let .meeting(meeting, standup):
                            MeetingView(meeting: meeting, standup: standup)
                        case let .record(recordStandupModel):
                            RecordStandupView(model: recordStandupModel)
                        }
                    }
            }
            .sheet(unwrapping: $model.destination) { $destination in
                switch destination {
                case .add(let model):
                    NavigationStack {
                        EditStandupView(model: model)
                    }
                }
            }
        }
    }
}
