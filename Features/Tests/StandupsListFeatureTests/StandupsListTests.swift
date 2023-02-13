import XCTest
import CustomDump
import Dependencies

import Models
@testable import StandupsListFeature

@MainActor
class StandupsListTests: XCTestCase {
    func testPersistenceAcrossModelCreation() async throws {
        withDependencies {
            $0.standupsProvider = .mock()
        } operation: {
            let listModel = StandupsListModel()
            XCTAssertEqual(listModel.standups.count, 0)

            listModel.standups.append(.init(id: .init(UUID())))

            let nextLaunchListModel = StandupsListModel()
            XCTAssertEqual(nextLaunchListModel.standups.count, 1)
        }
    }

    func testOnAddStandupTriggers() async throws {
        withDependencies {
            $0.standupsProvider = .mock()
        } operation: {
            let listModel = StandupsListModel()
            listModel.onAddStandupTapped = {
                self.expectation(description: "onAddStandupTapped").fulfill()
            }

            listModel.addStandupButtonTapped()
            waitForExpectations(timeout: 0)
        }
    }
}

