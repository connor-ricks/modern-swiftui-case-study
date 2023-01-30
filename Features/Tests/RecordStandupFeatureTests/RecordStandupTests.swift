import Dependencies
import XCTest

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
            let expectation = self.expectation(description: "onMeetingFinished")
            recordModel.onMeetingFinished = { _ in expectation.fulfill() }
            
            await recordModel.task()
            self.wait(for: [expectation], timeout: 0)
            XCTAssertEqual(recordModel.secondsElapsed, 6)
            XCTAssertEqual(recordModel.dismiss, true)
        }
    }
}
