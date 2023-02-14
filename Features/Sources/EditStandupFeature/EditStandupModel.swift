import SwiftUI
import SwiftUINavigation
import Dependencies
import XCTestDynamicOverlay

import Models

public class EditStandupModel: ViewModel {

    // MARK: Destination

    public enum Destination {
        case alert(AlertState<Void>)
    }

    // MARK: Properties


    let navigationTitle: String
    
    @Dependency(\.uuid) var uuid

    @Published var destination: Destination?
    @Published var focus: EditStandupView.Field?
    @Published var standup: Standup

    public var onEditingFinished: (Standup) -> Void = unimplemented("EditStandupModel.onEditingFinished")
    public var onEditingCanceled: () -> Void = unimplemented("EditStandupModel.onEditingCanceled")
    
    // MARK: Initializers
    
    public init(focus: EditStandupView.Field? = .title, standup: Standup? = nil) {
        @Dependency(\.uuid) var uuid

        self.navigationTitle = standup?.title ?? "New Standup"
        self.focus = focus
        self.standup = standup ?? .init(id: .init(uuid()))
        super.init()
        
        if self.standup.attendees.isEmpty {
            self.standup.attendees.append(Attendee(id: Attendee.ID(uuid()), name: ""))
        }
    }
    
    // MARK: Actions
    
    func deleteAttendees(atOffsets indices: IndexSet) {
        standup.attendees.remove(atOffsets: indices)
        if standup.attendees.isEmpty {
            standup.attendees.append(Attendee(id: Attendee.ID(uuid()), name: ""))
        }
        
        let index = min(indices.first!, standup.attendees.count - 1)
        focus = .attendee(standup.attendees[index].id)
    }
    
    func addAttendeeButtonTapped() {
        let attendee = Attendee(id: Attendee.ID(uuid()), name: "")
        standup.attendees.append(attendee)
        focus = .attendee(attendee.id)
    }

    func finishEditingButtonTapped() {
        if standup.title.isEmpty || standup.title.allSatisfy(\.isWhitespace) {
            destination = .alert(
                AlertState(
                    title: TextState("Oops!"),
                    message: TextState("You cannot save a standup without a title."),
                    buttons: [.default(TextState("Okay"))]
                )
            )
        } else {
            standup.attendees = standup.attendees.filter { !$0.name.allSatisfy(\.isWhitespace) }
            onEditingFinished(standup)
        }
    }

    func cancelEditingButtonTapped() {
        onEditingCanceled()
    }
}
