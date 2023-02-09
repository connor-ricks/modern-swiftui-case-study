import SwiftUI
import SwiftUINavigation
import SwiftUINavigationBackport

import Models
import StandupDetailFeature

// MARK: - StandupsListView

public struct StandupsListView: View {
    
    // MARK: Properties
    
    @ObservedObject private var model: StandupsListModel
    
    // MARK: Initializers
    
    public init(model: StandupsListModel) {
        self.model = model
    }
    
    // MARK: Body
    
    public var body: some View {
        List {
            ForEach(model.standups) { standup in
                Button(action: { model.standupTapped(standup: standup) }) {
                    CardView(standup: standup)
                }
                .listRowBackground(standup.theme.primaryColor)
            }
        }
        .toolbar {
            Button(action: { model.addStandupButtonTapped() }) {
                Image(systemName: "plus")
            }
        }
        .navigationTitle(navigationTitle)
//        .navigationDestination(
//            unwrapping: $model.destination,
//            case: /StandupsListModel.Destination.detail
//        ) { $detailModel in
//            StandupDetailView(model: detailModel)
//        }
//        .sheet(
//            unwrapping: $model.destination,
//            case: /StandupsListModel.Destination.add
//        ) { $model in
//            NavigationView {
//                EditStandupView(model: model)
//                    .navigationTitle("New standup")
//                    .toolbar {
//                        ToolbarItem(placement: .cancellationAction) {
//                            Button("Dismiss") { self.model.dismissAddStandupButtonTapped() }
//                        }
//                        ToolbarItem(placement: .confirmationAction) {
//                            Button("Add") { self.model.confirmAddStandupButtonTapped() }
//                        }
//                    }
//            }
//        }
    }

    // MARK: Helpers

    var navigationTitle: String {
        if let attendee = model.attendee {
            return "\(attendee.name)'s Standups"
        } else {
            return "Daily Standups"
        }
    }
}

// MARK: - StandupsListView+Previews

struct StandupsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StandupsListView(
                model: StandupsListModel(
                    destination: .add(
                        EditStandupModel(
                            focus: .attendee(Standup.mock.attendees[3].id),
                            standup: .mock
                        )
                    )
                )
            )
        }
    }
}
