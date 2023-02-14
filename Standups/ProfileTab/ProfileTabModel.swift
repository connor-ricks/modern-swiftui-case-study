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
    var onDeepLinkDetailStandup: (Standup, Bool) -> Void = unimplemented("ProfileTabModel.onDeepLinkDetailStandup")

    @Dependency(\.standupsProvider) var standupsProvider
    @Published var standups: IdentifiedArrayOf<Standup> = []
    @Published var deeplinkToEdit: Bool = false

    // MARK: Initializers

    override init() {
        super.init()
//        standups = (try? standupsProvider.load()) ?? []
    }

    // MARK: Actions

    func deeplink(to standup: Standup) {
        onDeepLinkDetailStandup(standup, deeplinkToEdit)
    }
}
