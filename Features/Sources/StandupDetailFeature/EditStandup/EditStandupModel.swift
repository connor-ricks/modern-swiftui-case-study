import SwiftUI

import Models

public class EditStandupModel: ObservableObject {
    
    // MARK: Properties
    
    @Published public var focus: EditStandupView.Field?
    @Published public var standup: Standup
    
    // MARK: Initializers
    
    public init(focus: EditStandupView.Field? = .title, standup: Standup) {
        self.focus = focus
        self.standup = standup
        
        if standup.attendees.isEmpty {
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
}
