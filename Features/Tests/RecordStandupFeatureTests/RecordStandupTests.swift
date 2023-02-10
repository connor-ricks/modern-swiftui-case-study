import XCTest
import Dependencies

import Models
@testable import RecordStandupFeature

@MainActor
class RecordMeetingTests: XCTestCase {
    func testTimer() async {
        await withDependencies {
            $0.speechClient.requestAuthorization = { .denied }
        } operation: {
            var standup = Standup.mock
            standup.duration = 6
            let recordModel = RecordStandupModel(standup: standup)

            let mockDelegate = MockDelegate()
            recordModel.delegate = mockDelegate

            await recordModel.task()
            self.wait(for: [mockDelegate.didFinishExpectation], timeout: 0)
            XCTAssertEqual(recordModel.secondsElapsed, 6)
            XCTAssertEqual(recordModel.dismiss, true)
        }
    }

    class MockDelegate: RecordStandupModelDelegate {
        let didFinishExpectation: XCTestExpectation = XCTestExpectation(description: "didFinishMeeting")
        let didCancelExpectation: XCTestExpectation = XCTestExpectation(description: "didCancelMeeting")

        init() {}

        func recordStandupModel(_ model: RecordStandupModel, didCancelMeetingWith transcript: String) {
            didCancelExpectation.fulfill()
        }

        func recordStandupModel(_ model: RecordStandupModel, didFinishMeetingWith transcript: String) {
            didFinishExpectation.fulfill()
        }
    }
}
