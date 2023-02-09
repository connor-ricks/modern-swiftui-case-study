import SwiftUI
import Dependencies

// MARK: - DestinationService

@MainActor public protocol DestinationServiceDelegate: AnyObject {
    func service(_ service: DestinationService, didRequestNavigationTo tab: AppTab)

    associatedtype StandupList: View
    func service(_ service: DestinationService, didRequestPresentationOfStandupsListFor attendee: Attendee) -> StandupList

    associatedtype CreateStandup: View
    func service(_ service: DestinationService, didRequestPresentationOfCreateStandup: Bool) -> CreateStandup
}

@MainActor
public class DestinationService {

    // MARK: Properties

    public weak var delegate: (any DestinationServiceDelegate)?

    // MARK: Initializers

    private init() {}

    public func select(tab: AppTab) {
        delegate?.service(self, didRequestNavigationTo: tab)
    }

    public func standupsListView(for attendee: Attendee) -> AnyView {
        guard let view = delegate?.service(self, didRequestPresentationOfStandupsListFor: attendee) else {
            return AnyView(Text(""))
        }

        return AnyView(view)
    }

    public func createStandupView() -> AnyView {
        guard let view = delegate?.service(self, didRequestPresentationOfCreateStandup: true) else {
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
