//
//  StandupsTests.swift
//  StandupsTests
//
//  Created by Connor Ricks on 2/13/23.
//

import XCTest
import Combine
import CustomDump
import Dependencies
import Models

@testable import Standups
@testable import StandupsListFeature
@testable import StandupDetailFeature
@testable import EditStandupFeature

@MainActor
final class StandupsTests: XCTestCase {

    var cancellable: AnyCancellable?

    func testEdit() async {
        await withDependencies {
            $0.standupsProvider = .mock(
                initialData:[Standup.mock]
            )
        } operation: {
            let standupListModel = StandupsListModel()
            await standupListModel.task()
            let standupTabModel = StandupsTabModel(
                standupsListModel: standupListModel
            )

            XCTAssertEqual(standupTabModel.path.count, 0)

            let standupListModelExpectation = expectation(description: "standupListModel state updated")
            standupListModelExpectation.assertForOverFulfill = false
            cancellable = standupListModel.$state.sink { state in
                print(state)
                guard case .loaded = state else { return }
                standupListModelExpectation.fulfill()
            }
            waitForExpectations(timeout: 5)
            guard case var .loaded(standups) = standupListModel.state else {
                XCTFail()
                return
            }
            XCTAssertEqual(standups.count, 1)

            standupListModel.standupTapped(standup: standups[0])

            XCTAssertEqual(standupTabModel.path.count, 1)
            guard case let .detail(standupDetailModel) = standupTabModel.path.last else {
                XCTFail("No detail in path")
                return
            }

            XCTAssertNoDifference(standupDetailModel.standup, standups[0])
            standupDetailModel.editButtonTapped()

            guard case let .edit(editStandupModel) = standupTabModel.destination else {
                XCTFail("Incorrect destination!")
                return
            }
            XCTAssertNoDifference(editStandupModel.standup, standupDetailModel.standup)

            editStandupModel.standup.title = "Product"
            editStandupModel.finishEditingButtonTapped()

            XCTAssertNil(standupTabModel.destination)
            XCTAssertEqual(standupDetailModel.standup.title, "Product")

            guard case var .loaded(standups) = standupListModel.state else {
                XCTFail()
                return
            }
            XCTAssertEqual(standups[0].title, "Product")
        }
    }
}
