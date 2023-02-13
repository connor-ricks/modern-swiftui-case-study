import SwiftUI
import NavigationBackport
import SwiftUINavigation
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature

// MARK: - ProfileTabView

struct ProfileTabView: View {

    // MARK: Properties

    @ObservedObject private var model: ProfileTabModel

    // MARK: Initializer

    init(model: ProfileTabModel) {
        self.model = model
    }

    // MARK: Body

    var body: some View {
        NBNavigationStack {
            List {
                Section("Actions") {
                    Button("Switch Tabs") {
                        model.onSwitchTabsTapped()
                    }

                    Button("Add Standup") {
                        model.onAddStandupTapped()
                    }

                    Button("Edit First Standup") {
                        model.onEditFirstStandupTapped()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - ProfileTabView+Preview

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        withDependencies {
            $0.standupsProvider = .mock(initialData: [.mock])
        } operation: {
            ProfileTabView(model: .init())
        }
    }
}
