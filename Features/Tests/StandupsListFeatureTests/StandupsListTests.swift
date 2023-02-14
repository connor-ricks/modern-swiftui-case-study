import XCTest
import Combine
import CustomDump
import Dependencies

import Models
@testable import StandupsListFeature

@MainActor
class StandupsListTests: XCTestCase {

    var cancellable: Cancellable?

    func testPersistenceAcrossModelCreation() async throws {
        await withDependencies {
            $0.standupsProvider = .mock()
        } operation: {
            let listModel = StandupsListModel()
            await listModel.task()
            let listModelExpectation = expectation(description: "listModel state updated")
            listModelExpectation.assertForOverFulfill = false
            cancellable = listModel.$state.sink { state in
                print(state)
                guard case .loaded = state else { return }
                listModelExpectation.fulfill()
            }
            waitForExpectations(timeout: 5)

            guard case var .loaded(standups) = listModel.state else {
                XCTFail()
                return
            }

            XCTAssertEqual(standups.count, 0)

            standups.append(.init(id: .init(UUID())))
            listModel.state = .loaded(standups)

            let nextLaunchListModel = StandupsListModel()
            await nextLaunchListModel.task()
            let nextLaunchListModelExpectation = expectation(description: "listModel state updated")
            nextLaunchListModelExpectation.assertForOverFulfill = false
            cancellable = nextLaunchListModel.$state.sink { state in
                guard case .loaded = state else { return }
                nextLaunchListModelExpectation.fulfill()
            }
            waitForExpectations(timeout: 5)

            guard case let .loaded(nextLaunchStandups) = nextLaunchListModel.state else {
                XCTFail()
                return
            }
            XCTAssertEqual(nextLaunchStandups.count, 1)
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

