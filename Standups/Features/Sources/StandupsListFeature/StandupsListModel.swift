import SwiftUI
import Combine
import Dependencies
import IdentifiedCollections

import Models
import StandupDetailFeature

@MainActor
public class StandupsListModel: ObservableObject {
    
    // MARK: Constants
    
    private enum Constants {
        static let standupsURL: URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return URL(string: paths[0].absoluteString + "standups.json")!
        }()
    }
    
    // MARK: Destination
    
    public enum Destination {
        case add(EditStandupModel)
        case detail(StandupDetailModel)
    }
    
    // MARK: Properties
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.standupsProvider) var standupsProvider
    
    @Published public internal(set) var destination: Destination? { didSet { bind() } }
    @Published public internal(set) var standups: IdentifiedArrayOf<Standup>
    
    private var destinationCancellable: AnyCancellable?
    private var standupsDidChangeCancellable: AnyCancellable?
    
    // MARK: Initializers
    
    public init(destination: Destination? = nil) {
        self.destination = destination
        self.standups = []
        
        loadStandups()
        subscribeToStandupChanges()
        bind()
    }
    
    // MARK: Actions
    
    func addStandupButtonTapped() {
        /// `UUID` generation should be powered by a `@Dependency`.
        destination = .add(EditStandupModel(standup: Standup(id: Standup.ID(UUID()))))
    }
    
    func dismissAddStandupButtonTapped() {
        destination = nil
    }
    
    func confirmAddStandupButtonTapped() {
        defer { destination = nil }
        
        guard case let .add(editStandupModel) = destination else { return }
        var standup = editStandupModel.standup
        
        standup.attendees.removeAll { $0.name.allSatisfy(\.isWhitespace) }
        
        standups.append(standup)
    }
    
    func standupTapped(standup: Standup) {
        destination = .detail(StandupDetailModel(standup: standup))
    }
    
    // MARK: Helpers
    
    private func bind() {
        switch self.destination {
        case let .detail(standupDetailModel):
            standupDetailModel.onConfirmDeletion = { [weak self, id = standupDetailModel.standup.id] in
                guard let self else { return }
                withAnimation {
                    self.standups.remove(id: id)
                    self.destination = nil
                }
            }
            
            destinationCancellable = standupDetailModel.$standup
                .sink { [weak self] standup in
                    guard let self else { return }
                    self.standups[id: standup.id] = standup
                }
            
        case .add, .none:
            break
        }
    }
    
    private func subscribeToStandupChanges() {
        standupsDidChangeCancellable = $standups
            .debounce(for: .seconds(1), scheduler: mainQueue)
            .sink { [weak self] standups in
                guard let self else { return }
                self.saveStandups()
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
            standups = try standupsProvider.load()
        } catch {
            // TODO: Handle Errors!
        }
    }
}
