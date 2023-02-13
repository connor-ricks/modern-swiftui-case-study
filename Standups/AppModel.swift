import SwiftUI
import CasePaths
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature

// MARK: - AppModel

@MainActor
class AppModel: ViewModel {

    // MARK: Properties

    enum Tab {
        case standups
        case profile
    }

    // MARK: Properties

    @Published var selectedTab: Tab

    let standupsTabModel: StandupsTabModel
    let profileTabModel: ProfileTabModel

    // MARK: Initializers

    init(
        selectedTab: Tab = .standups,
        standupsTabModel: StandupsTabModel,
        profileTabModel: ProfileTabModel
    ) {
        self.selectedTab = selectedTab
        self.standupsTabModel = standupsTabModel
        self.profileTabModel = profileTabModel
        super.init()
        self.bind()
    }

    // MARK: Bind

    private func bind() {
        profileTabModel.onSwitchTabsTapped = { [weak self] in
            self?.selectedTab = .standups
        }

        profileTabModel.onAddStandupTapped = { [weak self] in
            self?.selectedTab = .standups
            self?.standupsTabModel.presentAddStandup()
        }

        profileTabModel.onEditFirstStandupTapped = { [weak self] in
            self?.selectedTab = .standups
            self?.standupsTabModel.presentEditStandup(for: .mock)
        }
    }
}
