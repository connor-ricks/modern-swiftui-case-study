import SwiftUI
import XCTestDynamicOverlay

import Models

// MARK: - EditStandupModelDelegate

public protocol EditStandupModelDelegate: AnyObject {
    func editStandupModel(_ model: EditStandupModel, didCancelEditing standup: Standup)
    func editStandupModel(_ model: EditStandupModel, didFinishEditing standup: Standup)
}

// MARK: - EditStandupModel

public class EditStandupModel: ObservableObject {
    
    // MARK: Properties

    let navigationTitle: String
    @Published var focus: EditStandupView.Field?
    @Published var standup: Standup

    public weak var delegate: EditStandupModelDelegate?
    
    // MARK: Initializers
    
    public init(focus: EditStandupView.Field? = .title, standup: Standup? = nil) {
        self.navigationTitle = standup?.title ?? "New Standup"
        self.focus = focus
        self.standup = standup ?? .init(id: .init(UUID()))
        
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

    func cancelEditingButtonTapped() {
        delegate?.editStandupModel(self, didCancelEditing: standup)
    }

    func finishEditingButtonTapped() {
        standup.attendees = standup.attendees.filter { !$0.name.allSatisfy(\.isWhitespace) }
        delegate?.editStandupModel(self, didFinishEditing: standup)
    }
}
