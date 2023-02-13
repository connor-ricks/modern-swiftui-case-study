//
//  StandupsTests.swift
//  StandupsTests
//
//  Created by Connor Ricks on 2/13/23.
//

import XCTest
import CustomDump
import Dependencies
import Models

@testable import Standups
@testable import StandupsListFeature
@testable import StandupDetailFeature
@testable import EditStandupFeature

@MainActor
final class StandupsTests: XCTestCase {

    func testEdit() {
        withDependencies {
            $0.standupsProvider = .mock(
                initialData:[Standup.mock]
            )
        } operation: {
            let standupListModel = StandupsListModel()
            let standupTabModel = StandupsTabModel(
                standupsListModel: standupListModel
            )

            XCTAssertEqual(standupTabModel.path.count, 0)
            XCTAssertEqual(standupListModel.standups.count, 1)
            standupListModel.standupTapped(standup: standupListModel.standups[0])

            XCTAssertEqual(standupTabModel.path.count, 1)
            guard case let .detail(standupDetailModel) = standupTabModel.path.last else {
                XCTFail("No detail in path")
                return
            }

            XCTAssertNoDifference(standupDetailModel.standup, standupListModel.standups[0])
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
            XCTAssertEqual(standupListModel.standups[0].title, "Product")
        }
    }
}



//
//    func testEdit() {
//        withDependencies {
//            $0.standupsProvider = .mock(
//                initialData:[Standup.mock]
//            )
//            $0.mainQueue = mainQueue.eraseToAnyScheduler()
//        } operation: {
//            let listModel = StandupsListModel()
//            XCTAssertEqual(listModel.standups.count, 1)
//
//            listModel.standupTapped(standup: listModel.standups[0])
//            guard case let .detail(detailModel) = listModel.destination else {
//                XCTFail()
//                return
//            }
//            XCTAssertNoDifference(detailModel.standup, listModel.standups[0])
//
//            detailModel.editButtonTapped()
//            guard case let .edit(editModel) = detailModel.destination else {
//                XCTFail()
//                return
//            }
//            XCTAssertNoDifference(editModel.standup, detailModel.standup)
//
//            editModel.standup.title = "Product"
//            detailModel.editStandupModel(editModel, didFinishEditing: editModel.standup)
//
//            XCTAssertNil(detailModel.destination)
//            XCTAssertEqual(detailModel.standup.title, "Product")
//
//            listModel.destination = nil
//
//            XCTAssertEqual(listModel.standups[0].title, "Product")
//        }
//    }
//
//    func testTappingStandupInvokesCorrectDestination() {
//        withDependencies {
//            $0.standupsProvider = .mock(
//                initialData: [Standup.mock]
//            )
//            $0.mainQueue = mainQueue.eraseToAnyScheduler()
//        } operation: {
//            let listModel = StandupsListModel()
//            XCTAssertEqual(listModel.standups.count, 1)
//
//            listModel.standupTapped(standup: listModel.standups[0])
//            guard case let .detail(detailModel) = listModel.destination else {
//                XCTFail()
//                return
//            }
//            XCTAssertEqual(detailModel.standup, listModel.standups[0])
//        }
//    }
//
//    func testNamelessAttendees() throws {
//        let mainQueue = DispatchQueue.test
//
//        withDependencies {
//            $0.standupsProvider = .mock()
//            $0.mainQueue = mainQueue.eraseToAnyScheduler()
//        } operation: {
//            let listModel = StandupsListModel()
//            XCTAssertEqual(listModel.standups.count, 0)
//
//            listModel.addStandupButtonTapped()
//            guard case let .add(editModel) = listModel.destination else {
//                XCTFail()
//                return
//            }
//
//            editModel.standup.attendees = [
//                .init(id: .init(UUID()), name: "John"),
//                .init(id: .init(UUID()), name: "\t    ")
//            ]
//
//            editModel.finishEditingButtonTapped()
//            XCTAssertEqual(listModel.standups.count, 1)
//            XCTAssertEqual(listModel.standups[0].attendees.count, 1)
//            XCTAssertEqual(listModel.standups[0].attendees[0].name, "John")
//        }
//    }
//
