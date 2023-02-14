import SwiftUI
import SwiftUINavigation
import IdentifiedCollections
import NavigationBackport
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
            switch model.state {
            case .loading:
                VStack(alignment: .center) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            case let .loaded(standups):
                body(for: standups)
            case .error:
                VStack(alignment: .center) {
                    Text("Unable to load standups")
                    Button("Try Again") { model.tryAgainButtonTapped() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .task { await model.task() }
        .animation(.default, value: model.state)
        .navigationTitle("Daily Standups")
        .toolbar {
            Button(action: { model.addStandupButtonTapped() }) {
                Image(systemName: "plus")
            }
        }
    }

    private func body(for standups: IdentifiedArrayOf<Standup>) -> some View {
        ForEach(standups) { standup in
            Button(action: { model.standupTapped(standup: standup) }) {
                CardView(standup: standup)
            }
            .listRowBackground(standup.theme.primaryColor)
        }
    }
}

// MARK: - StandupsListView+Previews

struct StandupsListView_Previews: PreviewProvider {
    static var previews: some View {
        NBNavigationStack {
            withDependencies {
                $0.standupsProvider = .liveValue
//                $0.standupsProvider = .mock(initialData: [.mock])
            } operation: {
                StandupsListView(
                    model: StandupsListModel()
                )
            }
        }
    }
}
