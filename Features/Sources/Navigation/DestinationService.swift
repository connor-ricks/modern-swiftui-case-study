import SwiftUI
import Dependencies

// MARK: - DestinationService

@MainActor public protocol DestinationServiceDelegate: AnyObject {
    func service(_ service: DestinationService, requestedSwitchingTo tab: AppTab)
    func service(_ service: DestinationService, requestedDeepLinkingTo deeplink: DeepLinkableFeature)
    func service(_ service: DestinationService, requestedInjectableFeature feature: InjectableFeature) -> AnyView
}

@MainActor
public class DestinationService {

    // MARK: Properties


    public weak var delegate: (any DestinationServiceDelegate)?

    // MARK: Initializers

    private init() {}

    public func switchTo(tab: AppTab) {
        delegate?.service(self, requestedSwitchingTo: tab)
    }

    public func deepLink(to deeplink: DeepLinkableFeature) {
        guard let delegate else {
            assertionFailure("DestinationService does not have a delegate for deeplinking features.")
            return
        }

        delegate.service(self, requestedDeepLinkingTo: deeplink)
    }

    public func inject(feature: InjectableFeature) -> AnyView {
        guard let delegate else {
            assertionFailure("DestinationService does not have a delegate for injecting features.")
            return AnyView(EmptyView())
        }

        return delegate.service(self, requestedInjectableFeature: feature)
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
