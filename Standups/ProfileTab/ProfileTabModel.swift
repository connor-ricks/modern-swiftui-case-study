import SwiftUI
import CasePaths
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature

// MARK: - ProfileTabModel

@MainActor
class ProfileTabModel: ViewModel {

    // MARK: Properties

    var onSwitchTabsTapped: () -> Void =  unimplemented("ProfileTabModel.onSwitchTabsTapped")
    var onAddStandupTapped: () -> Void = unimplemented("ProfileTabModel.onAddStandupTapped")
    var onEditFirstStandupTapped: () -> Void = unimplemented("ProfileTabModel.onEditFirstStandupTapped")

    // MARK: Initializers

    override init() {
        super.init()
    }
}
