import SwiftUI
import Dependencies

// MARK: - DestinationService

@MainActor public protocol DestinationServiceDelegate: AnyObject {
    func service(_ service: DestinationService, didRequestNavigationTo tab: AppTab)
    func service(_ service: DestinationService, didRequestNavigationToEditStandupFor standup: Standup?)
    func service(_ service: DestinationService, didRequestPresentationOfStandupsListFor attendee: Attendee) -> AnyView
}

@MainActor
public class DestinationService {

    // MARK: Properties

    public weak var delegate: (any DestinationServiceDelegate)?

    // MARK: Initializers

    private init() {}

    public func navigateTo(tab: AppTab) {
        delegate?.service(self, didRequestNavigationTo: tab)
    }

    public func navigateToCreateStandup() {
        delegate?.service(self, didRequestNavigationToEditStandupFor: nil)
    }

    public func standupsListView(for attendee: Attendee) -> AnyView {
        guard let view = delegate?.service(self, didRequestPresentationOfStandupsListFor: attendee) else {
            return AnyView(Text(""))
        }

        return AnyView(view)
    }
}

public extension DependencyValues {
    var destinationService: DestinationService {
        get { self[DestinationService.self] }
        set { self[DestinationService.self] = newValue }
    }
}

extension DestinationService: DependencyKey {
    static public let liveValue = DestinationService()
}
