import XCTest
import Models
@testable import StandupDetailFeature

@MainActor
class StandupDetailTests: XCTestCase {
    func testMeetingDeletion() {
        let model = StandupDetailModel(standup: .mock)
        XCTAssertEqual(model.standup,  Standup.mock)
        XCTAssertEqual(model.standup.meetings.count, 1)
        model.deleteMeetings(atOffsets: .init(integer: 0))
        XCTAssertTrue(model.standup.meetings.isEmpty)
    }
}
