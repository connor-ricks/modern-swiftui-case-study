import SwiftUI
import NavigationBackport
import SwiftUINavigation
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature

// MARK: - StandupsTabView

struct StandupsTabView: View {

    // MARK: Properties

    @ObservedObject private var model: StandupsTabModel

    // MARK: Initializer

    init(model: StandupsTabModel) {
        self.model = model
    }

    // MARK: Body

    var body: some View {
        NBNavigationStack(path: self.$model.path) {
            StandupsListView(model: model.standupsListModel)
                .nbNavigationDestination(for: StandupTabPathComponent.self) { path in
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
                NBNavigationStack {
                    EditStandupView(model: model)
                }
            }
        }
    }
}

// MARK: - StandupsTabView+Preview

struct StandupsTabView_Previews: PreviewProvider {
    static var previews: some View {
        withDependencies {
            $0.standupsProvider = .mock(initialData: [.mock])
        } operation: {
            StandupsTabView(model: .init(
                path: [],
                destination: nil,
                standupsListModel: .init()
            ))
        }
    }
}
