import SwiftUI
import CasePaths
import Dependencies

import Models
import StandupsListFeature
import StandupDetailFeature
import EditStandupFeature
import RecordStandupFeature

// MARK: - StandupsAppModel

@MainActor
class StandupsAppModel: ViewModel {

    // MARK: Properties

    @Published var path: [RootPath] {
        didSet { bind() }
    }

    @Published var destination: RootDestination? = nil {
        didSet { bind() }
    }

    @Published var standupsListModel: StandupsListModel {
        didSet { bind() }
    }

    // MARK: Initializers

    init(
        path: [RootPath] = [],
        destination: RootDestination? = nil,
        standupsListModel: StandupsListModel
    ) {
        self.path = path
        self.destination = destination
        self.standupsListModel = standupsListModel
        super.init()
        self.bind()
    }

    // MARK: Bind

    private func bind() {
        print("Path: \(path.debugDescription)")
        print("Destination: \(destination.debugDescription)")

        // Bind Root View
        bind(standupsListModel: standupsListModel)

        // Bind Path
        for item in path {
            switch item {
            case let .detail(standupDetailModel):
                bind(standupDetailModel: standupDetailModel)
            case .meeting:
                break
            case let .record(recordStandupModel):
                guard let standupDetailModel = path.compactMap(/RootPath.detail).last else {
                    assertionFailure("Attempting to record a Standup without a StandupDetailModel in the path.")
                    return
                }

                bind(recordStandupModel: recordStandupModel, to: standupDetailModel)
            }
        }

        // Bind Destination
        switch destination {
        case let .add(editStandupModel):
            bind(editStandupModel: editStandupModel, to: standupsListModel)
        case let .edit(editStandupModel):
            guard let standupDetailModel = path.compactMap(/RootPath.detail).last else {
                assertionFailure("Attempting to edit a Standup without a StandupDetailModel in the path.")
                return
            }

            bind(editStandupModel: editStandupModel, to: standupDetailModel)
        case .none:
            break
        }
    }
}

// MARK: - StandupsAppModel+StandupsListModel Binding

extension StandupsAppModel {
    private func bind(standupsListModel: StandupsListModel) {
        standupsListModel.onStandupTapped = { [weak self] standup in
            self?.path.append(
                .detail(model: StandupDetailModel(standup: standup))
            )
        }

        standupsListModel.onAddStandupTapped = { [weak self] in
            self?.destination = .add(EditStandupModel())
        }
    }
}

// MARK: - StandupsAppModel+StandupDetailModel Binding

extension StandupsAppModel {
    private func bind(standupDetailModel: StandupDetailModel) {
        standupDetailModel.onEditTapped = { [weak self] standup in
            self?.destination = .edit(EditStandupModel(standup: standup))
        }

        standupDetailModel.onDeleteTapped = { [weak self] standup in
            self?.standupsListModel.standups.remove(id: standup.id)
            _ = self?.path.popLast()
        }

        standupDetailModel.onMeetingTapped = { [weak self] standup, meeting in
            self?.path.append(.meeting(meeting, standup: standup))
        }

        standupDetailModel.onStartMeetingTapped = { [weak self] standup in
            self?.path.append(.record(.init(standup: standup)))
        }

        standupDetailModel.onStandupDidChange = { [weak self] standup in
            self?.standupsListModel.standups[id: standup.id] = standup
        }
    }
}

// MARK: - StandupsAppModel+RecordStandupModel Binding

extension StandupsAppModel {
    private func bind(recordStandupModel: RecordStandupModel, to standupDetailModel: StandupDetailModel) {
        recordStandupModel.onMeetingFinished = { [weak self] transcript in
            let meeting = Meeting(id: .init(rawValue: UUID()), date: Date(), transcript: transcript)
            standupDetailModel.standup.meetings.insert(meeting, at: 0)
            _ = self?.path.popLast()
        }

        recordStandupModel.onDiscardMeeting = { [weak self] in
            _ = self?.path.popLast()
        }
    }
}

// MARK: - StandupsAppModel+EditStandupModel Binding

extension StandupsAppModel {
    private func bind(editStandupModel: EditStandupModel, to standupListModel: StandupsListModel) {
        editStandupModel.onEditingCanceled = { [weak self] in
            self?.destination = nil
        }

        editStandupModel.onEditingFinished = { [weak self] standup in
            self?.standupsListModel.standups.append(standup)
            self?.destination = nil
        }
    }

    private func bind(editStandupModel: EditStandupModel, to standupDetailModel: StandupDetailModel) {
        editStandupModel.onEditingCanceled = { [weak self] in
            self?.destination = nil
        }

        editStandupModel.onEditingFinished = { [weak self] standup in
            standupDetailModel.standup = standup
            self?.destination = nil
        }
    }
}
