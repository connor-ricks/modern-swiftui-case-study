import SwiftUI
import CasePaths
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature

// MARK: - AppModel

@MainActor
class AppModel: ViewModel {

    // MARK: Properties

    enum Tab: String {
        case standups
        case profile
    }

    // MARK: Properties

    @Published var selectedTab: Tab

    let standupsTabModel: StandupsTabModel
    let profileTabModel: ProfileTabModel

    // MARK: Initializers

    init(
        selectedTab: Tab = .standups,
        standupsTabModel: StandupsTabModel,
        profileTabModel: ProfileTabModel
    ) {
        self.selectedTab = selectedTab
        self.standupsTabModel = standupsTabModel
        self.profileTabModel = profileTabModel
        super.init()
        self.bind()
    }

    // MARK: Bind

    private func bind() {
        profileTabModel.onSwitchTabsTapped = { [weak self] in
            self?.selectedTab = .standups
        }

        profileTabModel.onAddStandupTapped = { [weak self] in
            self?.selectedTab = .standups
            self?.standupsTabModel.presentAddStandup()
        }

        profileTabModel.onEditFirstStandupTapped = { [weak self] in
            self?.selectedTab = .standups
            self?.standupsTabModel.presentEditStandup(for: .mock)
        }

        profileTabModel.onDeepLinkDetailStandup = { [weak self] standup, shouldEdit in
            self?.open(url: "standups://standups/\(standup.id)?edit=\(String(shouldEdit))")
        }
    }

    // MARK: DeepLink

    func open(url: String) {
//        guard let components = URLComponents(string: url),
//              let tab = AppModel.Tab(rawValue: components.scheme ?? "")
//        else {
//            return
//        }
//
//        switch tab {
//        case .standups:
//            var path = ArraySlice(components.path.components(separatedBy: "/").filter { !$0.allSatisfy(\.isWhitespace) })
//
//            var id: Standup.ID
//            if let string = path.popFirst(),
//               let uuid = UUID(uuidString: string) {
//                id = .init(uuid)
//            } else {
//                assertionFailure("No Standup ID specified")
//                return
//            }
//
//            guard let standup = self.standupsTabModel.standupsListModel.standups[id: id] else {
//                assertionFailure("Invalid Standup ID")
//                return
//            }
//
//            var editPath: StandupTabPathComponent? = nil
//            if let item = components.queryItems?.first(where: { $0.name == "edit" }),
//               let value = Bool(item.value ?? "") {
//
//            }
//
//            selectedTab = .standups
//            standupsTabModel.path = [.detail(model: .init(standup: standup))]
//        case .profile:
//            break
//        }
    }
}
