import SwiftUI
import SwiftUINavigation
import Dependencies

import Models

// MARK: - StandupsListView

public struct StandupsListView: View {
    
    // MARK: Properties
    
    @ObservedObject private var model: StandupsListModel
    
    // MARK: Initializers
    
    public init(model: StandupsListModel) {
        self.model = model
    }
    
    // MARK: Body
    
    public var body: some View {
        List {
            ForEach(model.standups) { standup in
                Button(action: { model.standupTapped(standup: standup) }) {
                    CardView(standup: standup)
                }
                .listRowBackground(standup.theme.primaryColor)
            }
        }
        .toolbar {
            Button(action: { model.addStandupButtonTapped() }) {
                Image(systemName: "plus")
            }
        }
        .navigationTitle("Daily Standups")
    }
}

 // MARK: - StandupsListView+Previews

struct StandupsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            withDependencies {
                $0.standupsProvider = .mock(initialData: [.mock])
            } operation: {
                StandupsListView(
                    model: StandupsListModel()
                )
            }
        }
    }
}
