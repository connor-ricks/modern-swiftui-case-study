import XCTest
import Dependencies

import Models
@testable import RecordStandupFeature

@MainActor
class RecordMeetingTests: XCTestCase {
    func testTimer() async {
        await withDependencies {
            $0.speechClient.requestAuthorization = { .authorized }
        } operation: {
            var standup = Standup.mock
            standup.duration = 6
            let recordModel = RecordStandupModel(standup: standup)

            let expectation = expectation(description: "onMeetingFinished")
            recordModel.onMeetingFinished = { _ in
                expectation.fulfill()
            }

            await recordModel.task()
            
            self.waitForExpectations(timeout: 10)
            XCTAssertEqual(recordModel.secondsElapsed, 6)
        }
    }
}


//withDependencies {
//    $0.speechClient.requestAuthorization = { .authorized }
//} operation: {
//    NBNavigationStack {
//        RecordStandupView(
//            model: RecordStandupModel(standup: .mock)
//        )
//    }
//}
