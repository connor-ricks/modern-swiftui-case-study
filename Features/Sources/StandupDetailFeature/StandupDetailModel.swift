import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay
import Dependencies

import Models

@MainActor
public class StandupDetailModel: ViewModel {
    
    // MARK: Properties

    @Published public var standup: Standup { didSet { onStandupDidChange(standup) } }

    public var onEditTapped: (Standup) -> Void =  unimplemented("StandupDetailModel.onEditTapped")
    public var onDeleteTapped: (Standup) -> Void = unimplemented("StandupDetailModel.onDeleteTapped")
    public var onMeetingTapped: (Standup, Meeting) -> Void = unimplemented("StandupDetailModel.onMeetingTapped")
    public var onStartMeetingTapped: (Standup) -> Void = unimplemented("StandupDetailModel.onStartMeetingTapped")
    public var onStandupDidChange: (Standup) -> Void = unimplemented("StandupDetailModel.onStandupDidChange")
    
    // MARK: Initializers
    
    public init(standup: Standup) {
        self.standup = standup
        super.init()
    }

    public init?(id: Standup.ID) async {
        @Dependency(\.standupsProvider) var standupsProvider
        guard let standup = (try? await standupsProvider.load())?.first(where: { $0.id == id }) else {
            return nil
        }

        self.standup = standup
        super.init()
    }
    
    // MARK: Actions
    
    func deleteButtonTapped() {
        onDeleteTapped(standup)
    }
    
    func editButtonTapped() {
        onEditTapped(standup)
    }

    func deleteMeetings(atOffsets indices: IndexSet) {
        standup.meetings.remove(atOffsets: indices)
    }

    func meetingTapped(_ meeting: Meeting) {
        onMeetingTapped(standup, meeting)
    }
    
    func startMeetingButtonTapped() {
        onStartMeetingTapped(standup)
    }
}
