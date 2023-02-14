import SwiftUI
import Dependencies
import IdentifiedCollections

import Models

@MainActor
final public class StandupsListModel: ObservableObject {

    // MARK: State

    public enum State: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Standup>)
        case error
    }

    // MARK: Properties
    
    @Dependency(\.standupsProvider) var standupsProvider

    @Published public var state: State {
        didSet {
            saveStandups()
        }
    }
    
    public var onAddStandupTapped: () -> Void = unimplemented("StandupsListModel.onAddStandupTapped")
    public var onStandupTapped: (Standup) -> Void = unimplemented("StandupsListModel.onStandupTapped")
    
    // MARK: Initializers
    
    public init() {
        self.state = .loading
    }
    
    // MARK: Actions
    
    func addStandupButtonTapped() {
        onAddStandupTapped()
    }
    
    func standupTapped(standup: Standup) {
        onStandupTapped(standup)
    }

    func tryAgainButtonTapped() {
        Task {
            state = .loading
            await loadStandups()
        }
    }

    func task() async {
        await loadStandups()
    }
    
    // MARK: Persistence
    
    private func saveStandups() {
        guard case let .loaded(standups) = state else { return }
        try? standupsProvider.save(standups)
    }
    
    private func loadStandups() async {
        do {
            self.state = .loaded(try await standupsProvider.load())
        } catch {
            self.state = .error
        }
    }
}
