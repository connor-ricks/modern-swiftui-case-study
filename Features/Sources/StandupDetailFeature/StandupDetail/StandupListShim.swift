import SwiftUI

public protocol StandupDetailToStandupListModel: ObservableObject {
    init()
}

/// Example of handling cyclical dependencies.
/// (The StandupDetailFeature view is presented by the StandupListFeature, but the StandupDetailFeature also wants to present the StandupListFeature)
public protocol StandupDetailToStandupListView: View {
    associatedtype Model: StandupDetailToStandupListModel
    init(model: Model)
}

