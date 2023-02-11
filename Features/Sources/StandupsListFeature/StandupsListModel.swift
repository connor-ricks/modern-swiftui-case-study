import SwiftUI
import Dependencies
import IdentifiedCollections

import Models

@MainActor
final public class StandupsListModel: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.standupsProvider) var standupsProvider
    @Published public var standups: IdentifiedArrayOf<Standup>
    
    public var onAddStandupTapped: () -> Void = unimplemented("StandupsListModel.onAddStandupTapped")
    public var onStandupTapped: (Standup) -> Void = unimplemented("StandupsListModel.onStandupTapped")
    
    // MARK: Initializers
    
    public init() {
        self.standups = []
        self.loadStandups()
    }
    
    // MARK: Actions
    
    func addStandupButtonTapped() {
        onAddStandupTapped()
    }
    
    func standupTapped(standup: Standup) {
        onStandupTapped(standup)
    }
    
    // MARK: Persistence
    
    private func saveStandups() {
        do {
            try standupsProvider.save(standups)
        } catch {
            // TODO: Handle Errors!
        }
    }
    
    private func loadStandups() {
        do {
            self.standups = try standupsProvider.load()
        } catch {
            // TODO: Handle Errors!
        }
    }
}
