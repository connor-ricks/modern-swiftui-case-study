import Foundation
import Tagged
import IdentifiedCollections

// MARK: - Standup

public struct Standup: Equatable, Identifiable, Codable {
    public let id: Tagged<Self, UUID>
    public var attendees: IdentifiedArrayOf<Attendee> = []
    public var duration = TimeInterval(300)
    public var meetings: IdentifiedArrayOf<Meeting> = []
    public var theme: StandupTheme = .bubblegum
    public var title = ""
    
    public var durationPerAttendee: TimeInterval {
        duration / TimeInterval(max(attendees.count, 1))
    }
    
    public init(
        id: Tagged<Self, UUID>,
        attendees: IdentifiedArrayOf<Attendee> = [],
        duration: TimeInterval = 300,
        meetings: IdentifiedArrayOf<Meeting> = [],
        theme: StandupTheme = .bubblegum,
        title: String = ""
    ) {
        self.id = id
        self.attendees = attendees
        self.duration = duration
        self.meetings = meetings
        self.theme = theme
        self.title = title
    }
}

// MARK: - Standup+Mocks

#if DEBUG
extension Standup {
    public static let mock = Self(
        id: Standup.ID(UUID()),
        attendees: [
            Attendee(id: Attendee.ID(UUID()), name: "Blob"),
            Attendee(id: Attendee.ID(UUID()), name: "Blob Jr"),
            Attendee(id: Attendee.ID(UUID()), name: "Blob Sr"),
            Attendee(id: Attendee.ID(UUID()), name: "Blob Esq"),
            Attendee(id: Attendee.ID(UUID()), name: "Blob III"),
            Attendee(id: Attendee.ID(UUID()), name: "Blob I"),
        ],
        duration: 60,
        meetings: [
            Meeting(
                id: Meeting.ID(UUID()),
                date: Date().addingTimeInterval(-60 * 60 * 24 * 7),
                transcript: """
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
          incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
          exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure \
          dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \
          Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt \
          mollit anim id est laborum.
          """
            )
        ],
        theme: .orange,
        title: "Design"
    )
}
#endif
