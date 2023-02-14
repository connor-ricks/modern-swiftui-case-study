import XCTest
import Dependencies

import Models
@testable import EditStandupFeature

@MainActor
class EditStandupTests: XCTestCase {
    func testDeletion() {
        let model = EditStandupModel(
            standup: Standup(
                id: Standup.ID(UUID()),
                attendees: [
                    Attendee(id: Attendee.ID(UUID()), name: "Blob"),
                    Attendee(id: Attendee.ID(UUID()), name: "Blob Jr"),
                ]
            )
        )

        model.deleteAttendees(atOffsets: [1])

        XCTAssertEqual(model.standup.attendees.count, 1)
        XCTAssertEqual(model.standup.attendees[0].name, "Blob")

        XCTAssertEqual(model.focus, .attendee(model.standup.attendees[0].id))
    }

    func testAdd() {
        let id = UUID()
        withDependencies {
            $0.uuid = UUIDGenerator { id }
        } operation: {
            let model = EditStandupModel(
                standup: .mock
            )

            XCTAssertEqual(model.standup.attendees.count, 6)
            XCTAssertEqual(model.focus, .title)
            model.addAttendeeButtonTapped()

            XCTAssertEqual(model.standup.attendees.count, 7)
            guard let lastAttendeeId = model.standup.attendees.last?.id.rawValue else {
                XCTFail()
                return
            }

            XCTAssertEqual(lastAttendeeId, id)
            XCTAssertEqual(model.focus, .attendee(.init(lastAttendeeId)))
        }
    }
}
