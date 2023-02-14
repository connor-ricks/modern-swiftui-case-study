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

    enum Tab: String {
        case standups
        case profile
    }

    // MARK: Properties

    @Published var selectedTab: Tab

    @Published var standupsTabModel: StandupsTabModel {
        didSet { bind() }
    }

    @Published var profileTabModel: ProfileTabModel {
        didSet { bind() }
    }

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

        profileTabModel.onDeepLink = { [weak self] url in
            await self?.open(url: url)
        }
    }

    // MARK: DeepLink

    func open(url: URL) async {
        guard let components = DeepLinkParser.target(for: url) else {
            print("Invalid DeepLink!")
            return
        }

        switch components.target {
        case .standups:
            guard let model = await DeepLinkParser.standupsTabModel(for: components.path, parameters: components.parameters) else {
                assertionFailure("Invalid DeepLink")
                return
            }

            standupsTabModel = model
            selectedTab = .standups
        case .profile:
            break
        }
    }
}
