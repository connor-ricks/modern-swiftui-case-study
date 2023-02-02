import SwiftUI
import XCTestDynamicOverlay
import SwiftUINavigation
import Dependencies

import Models
import RecordStandupFeature

// MARK: - StandupDetailModel

@MainActor
public class StandupDetailModel<V: StandupDetailToStandupListView>: ObservableObject {
    
    // MARK: Destination
    
    public enum Destination {
        case edit(EditStandupModel)
        case meeting(Meeting)
        case record(RecordStandupModel)
        case standups(V.Model)
    }
    
    // MARK: Properties
    
    @Published public internal(set) var destination: Destination? { didSet { bind() } }
    @Published public internal(set) var standup: Standup
    
    public var onConfirmDeletion: () -> Void =  unimplemented("StandupDetailModel.onConfirmDeletion")
    
    // MARK: Initializers
    
    public init(destination: Destination? = nil, standup: Standup) {
        self.destination = destination
        self.standup = standup
        self.bind()
    }
    
    // MARK: Actions
    
    func deleteMeetings(atOffsets indices: IndexSet) {
        standup.meetings.remove(atOffsets: indices)
    }
    
    func meetingTapping(_ meeting: Meeting) {
        destination = .meeting(meeting)
    }
    
    func deleteButtonTapped() {
        onConfirmDeletion()
    }
    
    func editButtonTapped() {
        destination = .edit(EditStandupModel(standup: standup))
    }
    
    func cancelEditButtonTapped() {
        destination = nil
    }
    
    func doneEditingButtonTapped() {
        guard case let .edit(model) = destination else { return }
        var standup = model.standup
        standup.attendees.removeAll { $0.name.allSatisfy(\.isWhitespace) }
        self.standup = standup
        destination = nil
    }
    
    func startMeetingButtonTapped() {
        destination = .record(RecordStandupModel(standup: standup))
    }
    
    func showAllStandupsButtonTapped() {
        destination = .standups(V.Model())
    }
    
    // MARK: Helpers
    
    private func bind() {
        switch destination {
        case let .record(model):
            model.onMeetingFinished = { [weak self] transcript in
                guard let self else { return }
                
                Task {
                    try? await Task.sleep(nanoseconds: 400_000_000) // Should be an injectable dependency.
                    withAnimation { self.recordStandup(transcript: transcript) }
                }
                
                self.destination = nil
            }
        case .standups, .edit, .meeting, .none:
            break
        }
    }
    
    private func recordStandup(transcript: String) {
        _ = standup.meetings.insert(Meeting(
            id: Meeting.ID(UUID()), /// `UUID` generation should be powered by a `@Dependency`.
            date: Date(), /// `Date` generation should be powered by a `@Dependency`.
            transcript: transcript
        ), at: 0)
    }
}
