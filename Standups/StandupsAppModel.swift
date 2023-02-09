//
//  StandupsAppModel.swift
//  Standups
//
//  Created by Connor Ricks on 2/8/23.
//

import SwiftUI
import Dependencies

import Models
import OtherFeature
import StandupDetailFeature
import StandupsListFeature

// MARK: - StandupsAppModel

@MainActor
class StandupsAppModel: ObservableObject {

    // MARK: Properties

    @Published var standupsListModel: StandupsListModel
    @Published var otherModel: OtherModel
    @Published var selectedTab: AppTab

    @Dependency(\.destinationService) var destinationService

    // MARK: Initializers

    init(
        selectedTab: AppTab = .standups,
        standupsListModel: StandupsListModel? = nil,
        otherModel: OtherModel? = nil
    ) {
        self.selectedTab = selectedTab
        self.standupsListModel = standupsListModel ?? .init()
        self.otherModel = otherModel ?? .init()
        destinationService.delegate = self
    }
}

// MARK: - StandupsAppModel+DestinationService

extension StandupsAppModel: DestinationServiceDelegate {
    func service(_ service: DestinationService, didRequestNavigationTo tab: AppTab) {
        selectedTab = tab
    }

    func service(_ service: DestinationService, didRequestNavigationToCreateStandup: Bool) -> some View {
        return EditStandupView(model: .init(standup: Standup(id: .init(UUID()))))
            .navigationTitle("New standup")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        print("Do something!")
                    }
                }
            }
    }

    func service(_ service: DestinationService, didRequestPresentationOfStandupsListFor attendee: Attendee) -> some View {
        StandupsListView(model: .init(for: attendee))
    }

}
