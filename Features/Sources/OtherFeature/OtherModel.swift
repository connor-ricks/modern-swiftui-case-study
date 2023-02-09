import SwiftUI
import Dependencies

import Models

@MainActor
public class OtherModel: ObservableObject {

    // MARK: Destination

    public enum Destination {
        case external(AnyView)
    }

    // MARK: Properties

    @Published var destination: Destination?

    @Dependency(\.destinationService) var destinationService

    // MARK: Initializers

    public init(destination: Destination? = nil) {
        self.destination = destination
    }

    // MARK: Actions

    func createNewStandupButtonTapped() {
        let view = destinationService.createStandupView()
        destination = .external(view)
    }
}
