import SwiftUI
import XCTestDynamicOverlay

import Models

public class EditStandupModel: ViewModel {
    
    // MARK: Properties

    let navigationTitle: String
    @Published var focus: EditStandupView.Field?
    @Published var standup: Standup

    public var onEditingFinished: (Standup) -> Void = unimplemented("EditStandupModel.onEditingFinished")
    public var onEditingCanceled: () -> Void = unimplemented("EditStandupModel.onEditingCanceled")
    
    // MARK: Initializers
    
    public init(focus: EditStandupView.Field? = .title, standup: Standup? = nil) {
        self.navigationTitle = standup?.title ?? "New Standup"
        self.focus = focus
        self.standup = standup ?? .init(id: .init(UUID()))
        super.init()
        
        if self.standup.attendees.isEmpty {
            /// `UUID` generation should be powered by a `@Dependency`.
            self.standup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
        }
    }
    
    // MARK: Actions
    
    func deleteAttendees(atOffsets indices: IndexSet) {
        standup.attendees.remove(atOffsets: indices)
        if standup.attendees.isEmpty {
            /// `UUID` generation should be powered by a `@Dependency`.
            standup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
        }
        
        let index = min(indices.first!, standup.attendees.count - 1)
        focus = .attendee(standup.attendees[index].id)
    }
    
    func addAttendeeButtonTapped() {
        /// `UUID` generation should be powered by a `@Dependency`.
        let attendee = Attendee(id: Attendee.ID(UUID()), name: "")
        standup.attendees.append(attendee)
        focus = .attendee(attendee.id)
    }

    func finishEditingButtonTapped() {
        standup.attendees = standup.attendees.filter { !$0.name.allSatisfy(\.isWhitespace) }
        onEditingFinished(standup)
    }

    func cancelEditingButtonTapped() {
        onEditingCanceled()
    }
}
