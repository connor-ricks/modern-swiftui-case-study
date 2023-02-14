import SwiftUI
import IdentifiedCollections
import Dependencies

import Models
import StandupsListFeature

// MARK: - ProfileTabModel

@MainActor
class ProfileTabModel: ViewModel {

    // MARK: Properties

    var onSwitchTabsTapped: () -> Void =  unimplemented("ProfileTabModel.onSwitchTabsTapped")
    var onAddStandupTapped: () -> Void = unimplemented("ProfileTabModel.onAddStandupTapped")
    var onEditFirstStandupTapped: () -> Void = unimplemented("ProfileTabModel.onEditFirstStandupTapped")
    var onDeepLink: (URL) async -> Void = unimplemented("ProfileTabModel.onDeepLinkDetailStandup")

    @Dependency(\.standupsProvider) var standupsProvider
    @Published var standups: IdentifiedArrayOf<Standup>?
    @Published var deeplinkToEdit: Bool = false

    @Published var isLoadingDeepLink: Bool = false

    // MARK: Initializers

    override init() {
        super.init()
        Task {
            self.standups = (try? await standupsProvider.load()) ?? []
        }
    }

    // MARK: Actions

    func deeplink(to standup: Standup) {
        let url = URL(string: "standups://standups/\(standup.id)?edit=\(String(deeplinkToEdit))")!

        Task {
            isLoadingDeepLink = true
            await onDeepLink(url)
            isLoadingDeepLink = false
        }
    }
}
