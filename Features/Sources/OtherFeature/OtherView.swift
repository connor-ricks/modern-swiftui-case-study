import SwiftUI
import SwiftUINavigation
import SwiftUINavigationBackport

import Models

public struct OtherView: View {

    // MARK: Properties

    @ObservedObject private var model: OtherModel

    // MARK: Initializers

    public init(model: OtherModel) {
        self.model = model
    }

    // MARK: Body
    
    public var body: some View {
        List {
            Section("Content") {
                Button("Create Standup") {
                    model.createNewStandupButtonTapped()
                }
            }
        }
        .navigationTitle("Other")
        .navigationDestination(
            unwrapping: $model.destination,
            case: /OtherModel.Destination.external
        ) { $view in
            view
        }
    }
}
