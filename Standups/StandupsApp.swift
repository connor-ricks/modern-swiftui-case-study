import SwiftUI
import Models

import StandupDetailFeature
import StandupsListFeature

@main
struct StandupsApp: App {
    var body: some Scene {
        WindowGroup {
            StandupsListView(model: .init(
                destination: .detail(
                    StandupDetailModel(destination: nil, standup: try! StandupsProvider.liveValue.load().first!)
                )
            ))
        }
    }
}
