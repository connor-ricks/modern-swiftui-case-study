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

            let expectation = expectation(description: "didFinishMeeting")
            recordModel.onMeetingFinished = {
                expectation.fulfill()
            }

            await recordModel.task()
            self.waitForExpectations(timeout: 10)
            XCTAssertEqual(recordModel.secondsElapsed, 6)
            XCTAssertEqual(recordModel.dismiss, true)
        }
    }
}
