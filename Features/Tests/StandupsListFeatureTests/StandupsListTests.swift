import XCTest
import CustomDump
import Dependencies

import Models
@testable import StandupsListFeature
@testable import StandupDetailFeature
@testable import EditStandupFeature

@MainActor
class StandupsListTests: XCTestCase {
    func testNamelessAttendees() throws {
        let mainQueue = DispatchQueue.test
        
        withDependencies {
            $0.standupsProvider = .mock()
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        } operation: {
            let listModel = StandupsListModel()
            XCTAssertEqual(listModel.standups.count, 0)
            
            listModel.addStandupButtonTapped()
            guard case let .add(editModel) = listModel.destination else {
                XCTFail()
                return
            }

            editModel.standup.attendees = [
                .init(id: .init(UUID()), name: "John"),
                .init(id: .init(UUID()), name: "\t    ")
            ]

            editModel.finishEditingButtonTapped()
            XCTAssertEqual(listModel.standups.count, 1)
            XCTAssertEqual(listModel.standups[0].attendees.count, 1)
            XCTAssertEqual(listModel.standups[0].attendees[0].name, "John")
        }
    }
    
    func testPersistence() async throws {
        let mainQueue = DispatchQueue.test
        
        await withDependencies {
            $0.standupsProvider = .mock()
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        } operation: {
            let listModel = StandupsListModel()
            XCTAssertEqual(listModel.standups.count, 0)

            listModel.addStandupButtonTapped()
            guard case let .add(editModel) = listModel.destination else {
                XCTFail()
                return
            }

            editModel.finishEditingButtonTapped()
            try? await Task.sleep(nanoseconds: 10000)

            let nextLaunchListModel = StandupsListModel()
            XCTAssertEqual(nextLaunchListModel.standups.count, 1)
        }
    }
    
    func testEdit() {
        let mainQueue = DispatchQueue.test
        
        withDependencies {
            $0.standupsProvider = .mock(
                initialData:[Standup.mock]
            )
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        } operation: {
            let listModel = StandupsListModel()
            XCTAssertEqual(listModel.standups.count, 1)
            
            listModel.standupTapped(standup: listModel.standups[0])
            guard case let .detail(detailModel) = listModel.destination else {
                XCTFail()
                return
            }
            XCTAssertNoDifference(detailModel.standup, listModel.standups[0])
            
            detailModel.editButtonTapped()
            guard case let .edit(editModel) = detailModel.destination else {
                XCTFail()
                return
            }
            XCTAssertNoDifference(editModel.standup, detailModel.standup)
            
            editModel.standup.title = "Product"
            detailModel.editStandupModel(editModel, didFinishEditing: editModel.standup)
            
            XCTAssertNil(detailModel.destination)
            XCTAssertEqual(detailModel.standup.title, "Product")
            
            listModel.destination = nil
            
            XCTAssertEqual(listModel.standups[0].title, "Product")
        }
    }
    
    func testTappingStandupInvokesCorrectDestination() {
        let mainQueue = DispatchQueue.test
        
        withDependencies {
            $0.standupsProvider = .mock(
                initialData: [Standup.mock]
            )
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        } operation: {
            let listModel = StandupsListModel()
            XCTAssertEqual(listModel.standups.count, 1)
            
            listModel.standupTapped(standup: listModel.standups[0])
            guard case let .detail(detailModel) = listModel.destination else {
                XCTFail()
                return
            }
            XCTAssertEqual(detailModel.standup, listModel.standups[0])
        }
    }
}
