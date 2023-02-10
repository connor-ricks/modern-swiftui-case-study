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
import EditStandupFeature
import StandupDetailFeature
import StandupsListFeature

// MARK: - StandupsAppModel

@MainActor
class StandupsAppModel: ObservableObject {

    // MARK: Properties

    @Published var standupsListModel: StandupsListModel
    @Published var otherModel: OtherModel
    @Published var selectedTab: AppTab {
        didSet { selectedTabDidChange(old: oldValue, new: selectedTab) }
    }

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

    // MARK: Helpers

    private func selectedTabDidChange(old: AppTab, new: AppTab) {
        switch (old, new) {
        case (.standups, .standups):
            standupsListModel = .init(destination: nil)
        default:
            break
        }
    }
}

// MARK: - StandupsAppModel+DestinationService

extension StandupsAppModel: DestinationServiceDelegate {
    func service(_ service: DestinationService, didRequestNavigationTo tab: AppTab) {
        selectedTab = tab
    }

    func service(_ service: DestinationService, didRequestNavigationToEditStandupFor standup: Standup?) {
        selectedTab = .standups
        standupsListModel = .init(
            destination: .add(
                EditStandupModel(standup: standup)
            )
        )
    }

    func service(_ service: DestinationService, didRequestPresentationOfStandupsListFor attendee: Attendee) -> AnyView {
        AnyView(
            StandupsListView(model: .init(for: attendee))
        )
    }

}
