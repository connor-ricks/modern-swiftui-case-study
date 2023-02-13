import XCTest

import Models
@testable import StandupDetailFeature

@MainActor
class StandupDetailTests: XCTestCase {
    func testCallbacks() {
        let model = StandupDetailModel(standup: .mock)
        let meeting = model.standup.meetings.last!

        XCTAssertEqual(model.standup,  Standup.mock)
        XCTAssertEqual(model.standup.meetings.count, 1)

        model.onEditTapped = { _ in
            self.expectation(description: "onEditTapped").fulfill()
        }

        model.onMeetingTapped = { _, m in
            XCTAssertEqual(meeting, m)
            self.expectation(description: "onMeetingTapped").fulfill()
        }

        model.onStartMeetingTapped = { _ in
            self.expectation(description: "onStartMeetingTapped").fulfill()
        }

        model.onDeleteTapped = { _ in
            self.expectation(description: "onDeleteTapped").fulfill()
        }


        model.onStandupDidChange = { _ in
            self.expectation(description: "onStandupDidChange").fulfill()
        }

        model.editButtonTapped()
        model.meetingTapped(Standup.mock.meetings.first!)
        model.startMeetingButtonTapped()
        model.deleteButtonTapped()
        model.deleteMeetings(atOffsets: .init(integer: 0))
        XCTAssertTrue(model.standup.meetings.isEmpty)
        waitForExpectations(timeout: 0)
    }
}
