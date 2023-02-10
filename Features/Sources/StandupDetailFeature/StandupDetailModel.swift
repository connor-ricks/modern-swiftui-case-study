import SwiftUI
import SwiftUINavigation
import SwiftUINavigationBackport
import XCTestDynamicOverlay
import Dependencies

import Navigation
import Models
import EditStandupFeature
import RecordStandupFeature

// MARK: - StandupDetailModelDelegate

public protocol StandupDetailModelDelegate: AnyObject {
    func standupDetailModel(_ model: StandupDetailModel, didRequestDeletionOf standup: Standup)
    func standupDetailModel(_ model: StandupDetailModel, didFinishEditing standup: Standup)
}

// MARK: - StandupDetailModel

@MainActor
public class StandupDetailModel: ObservableObject {
    
    // MARK: Destination
    
    public enum Destination {
        case edit(EditStandupModel)
        case meeting(Meeting)
        case record(RecordStandupModel)
        case externalPush(AnyView)
        case externalPresent(AnyView)
    }
    
    // MARK: Properties
    
    @Published var destination: Destination? { didSet { bind() } }
    @Published private(set) var standup: Standup

    public weak var delegate: StandupDetailModelDelegate?

    @Dependency(\.destinationService) var destinationService
    
    // MARK: Initializers
    
    public init(destination: Destination? = nil, standup: Standup) {
        self.destination = destination
        self.standup = standup
        self.bind()
    }
    
    // MARK: Actions
    
    func deleteMeetings(atOffsets indices: IndexSet) {
        standup.meetings.remove(atOffsets: indices)
        delegate?.standupDetailModel(self, didFinishEditing: standup)
    }
    
    func meetingTapping(_ meeting: Meeting) {
        destination = .meeting(meeting)
    }
    
    func deleteButtonTapped() {
        delegate?.standupDetailModel(self, didRequestDeletionOf: standup)
    }
    
    func editButtonTapped() {
        destination = .edit(EditStandupModel(standup: standup))
    }
    
    func startMeetingButtonTapped() {
        destination = .record(RecordStandupModel(standup: standup))
    }
    
    func pushAllStandupsButtonTapped(attendee: Attendee) {
        let view = destinationService.inject(feature: .standups(attendee: attendee))
        destination = .externalPush(view)
    }

    func presentAllStandupsButtonTapped(attendee: Attendee) {
        let view = destinationService.inject(feature: .standups(attendee: attendee))
        destination = .externalPresent(view)
    }

    func switchToOtherTabButtonTapped() {
        destinationService.switchTo(tab: .other)
    }
    
    // MARK: Helpers
    
    private func bind() {
        switch destination {
        case let .record(recordStandupModel):
            recordStandupModel.delegate = self
        case .edit(let editStandupModel):
            editStandupModel.delegate = self
        case .externalPush, .externalPresent, .meeting, .none:
            break
        }
    }
}

// MARK: - StandupDetailModel+EditStandupModelDelegate

extension StandupDetailModel: EditStandupModelDelegate {
    public func editStandupModel(_ model: EditStandupModel, didCancelEditing standup: Standup) {
        destination = nil
    }

    public func editStandupModel(_ model: EditStandupModel, didFinishEditing standup: Standup) {
        var standup = standup
        standup.attendees.removeAll { $0.name.allSatisfy(\.isWhitespace) }
        self.standup = standup
        destination = nil
        delegate?.standupDetailModel(self, didFinishEditing: standup)
    }
}

// MARK: - StandupDetailModel+RecordStandupModelDelegate

extension StandupDetailModel: RecordStandupModelDelegate {
    public func recordStandupModel(_ model: RecordStandupModel, didCancelMeetingWith transcript: String) {
        destination = nil
    }

    public func recordStandupModel(_ model: RecordStandupModel, didFinishMeetingWith transcript: String) {
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000) // Should be an injectable dependency.
            withAnimation {
                _ = standup.meetings.insert(Meeting(
                    id: Meeting.ID(UUID()), /// `UUID` generation should be powered by a `@Dependency`.
                    date: Date(), /// `Date` generation should be powered by a `@Dependency`.
                    transcript: transcript
                ), at: 0)
                delegate?.standupDetailModel(self, didFinishEditing: standup)
            }
        }

        destination = nil
    }
}
