import SwiftUI
import Dependencies

import Models

@MainActor
public class OtherModel: ObservableObject {

    // MARK: Properties

    @Dependency(\.destinationService) var destinationService

    // MARK: Initializers

    public init() {}

    // MARK: Actions

    func createNewStandupButtonTapped() {
        destinationService.deepLink(to: .createNewStandup)
    }
}
