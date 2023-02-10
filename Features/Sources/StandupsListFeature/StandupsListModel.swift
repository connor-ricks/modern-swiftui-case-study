import SwiftUI
import Dependencies
import IdentifiedCollections

import Models
import StandupDetailFeature
import EditStandupFeature

// MARK: - StandupsListModel

@MainActor
final public class StandupsListModel: ObservableObject {
    
    // MARK: Destination
    
    public enum Destination {
        case add(EditStandupModel)
        case detail(StandupDetailModel)
    }
    
    // MARK: Properties
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.standupsProvider) var standupsProvider
    
    let attendee: Attendee?
    @Published var destination: Destination? { didSet { bind() } }
    @Published private(set) var standups: IdentifiedArrayOf<Standup>
    
    // MARK: Initializers
    
    public init(for attendee: Attendee? = nil, destination: Destination? = nil) {
        self.destination = destination
        self.attendee = attendee
        self.standups = []
        
        loadStandups()
        bind()
    }
    
    // MARK: Actions
    
    func addStandupButtonTapped() {
        /// `UUID` generation should be powered by a `@Dependency`.
        destination = .add(EditStandupModel())
    }
    
    func standupTapped(standup: Standup) {
        destination = .detail(StandupDetailModel(standup: standup))
    }
    
    // MARK: Helpers
    
    private func bind() {
        switch self.destination {
        case let .detail(standupDetailModel):
            standupDetailModel.delegate = self
        case .add(let editStandupModel):
            editStandupModel.delegate = self
        case .none:
            break
        }
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
            let standups = try standupsProvider.load()
            if let attendee {
                self.standups = standups.filter { $0.attendees.contains(where: { $0.name == attendee.name })}
            } else {
                self.standups = standups
            }
            
        } catch {
            // TODO: Handle Errors!
        }
    }
}

// MARK: - StandupsListModel+EditStandupModelDelegate

extension StandupsListModel: EditStandupModelDelegate {
    public func editStandupModel(_ model: EditStandupModel, didCancelEditing standup: Standup) {
        destination = nil
    }

    public func editStandupModel(_ model: EditStandupModel, didFinishEditing standup: Standup) {
        standups.append(standup)
        saveStandups()
        destination = nil
    }
}

// MARK: - StandupListModel+StandupDetailModelDelegate

extension StandupsListModel: StandupDetailModelDelegate {
    public func standupDetailModel(_ model: StandupDetailModel, didFinishEditing standup: Standup) {
        standups[id: standup.id] = standup
        saveStandups()
    }

    public func standupDetailModel(_ model: StandupDetailModel, didRequestDeletionOf standup: Standup) {
        withAnimation {
            standups.remove(id: standup.id)
            saveStandups()
            destination = nil
        }
    }
}
