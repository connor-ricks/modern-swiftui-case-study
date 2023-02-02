import SwiftUI

/// Example of handling cyclical dependencies.
/// (The StandupDetailFeature view is presented by the StandupListFeature, but the StandupDetailFeature also wants to present the StandupListFeature)
public protocol StandupListModelFacade: ObservableObject {
    init()
}

public protocol StandupListViewFacade: View {
    associatedtype Model: StandupListModelFacade
    init(model: Model)
}

public protocol StandupDetailFeatureDependencies {
    associatedtype StandupListFacade: StandupListViewFacade
}
