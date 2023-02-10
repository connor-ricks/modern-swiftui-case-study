import SwiftUI
import Speech
import SwiftUINavigation
import Dependencies

import Models

// MARK: - RecordStandupModelDelegate

public protocol RecordStandupModelDelegate: AnyObject {
    func recordStandupModel(_ model: RecordStandupModel, didCancelMeetingWith transcript: String)
    func recordStandupModel(_ model: RecordStandupModel, didFinishMeetingWith transcript: String)
}

// MARK: - RecordStandupModel

@MainActor
public class RecordStandupModel: ObservableObject {
    
    // MARK: Destination
    
    public enum Destination {
        case alert(AlertState<AlertAction>)
    }
    
    // MARK: AlertAction
    
    public enum AlertAction {
        case confirmSave
        case confirmDiscard
    }
    
    // MARK: Properties
    
    @Dependency(\.speechClient) var speechClient
    
    @Published var destination: Destination?
    @Published private(set) var dismiss = false
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var speakerIndex = 0
    
    let standup: Standup
    
    private var transcript = ""

    public weak var delegate: RecordStandupModelDelegate?
    
    var durationRemaining: TimeInterval {
        self.standup.duration - TimeInterval(secondsElapsed)
    }
    
    var isAlertOpen: Bool {
        switch destination {
        case .alert:
            return true
        case .none:
            return false
        }
    }
    
    // MARK: Initializers
    
    public init(destination: Destination? = nil, standup: Standup) {
        self.destination = destination
        self.standup = standup
    }
    
    // MARK: Actions
    
    func nextButtonTapped() {
        guard self.speakerIndex < self.standup.attendees.count - 1 else {
            destination = .alert(
                AlertState(
                    title: TextState("End meeting?"),
                    message: TextState("You are ending the meeting early. What would you like to do?"),
                    buttons: [
                        .default(TextState("Save and end"), action: .send(.confirmSave)),
                        .cancel(TextState("Resume"))
                    ]
                )
            )
            return
        }
        
        speakerIndex += 1
        secondsElapsed = speakerIndex * Int(standup.durationPerAttendee)
    }
    
    func endMeetingButtonTapped() {
        destination = .alert(
            AlertState(
                title: TextState("End meeting?"),
                message: TextState("You are ending the meeting early. What would you like to do?"),
                buttons: [
                    .default(TextState("Save and end"), action: .send(.confirmSave)),
                    .destructive(TextState("Discard"), action: .send(.confirmDiscard)),
                    .cancel(TextState("Resume"))
                ]
            )
        )
    }
    
    func alertButtonTapped(_ action: AlertAction) {
        switch action {
        case .confirmSave:
            delegate?.recordStandupModel(self, didFinishMeetingWith: transcript)
            dismiss = true

        case .confirmDiscard:
            delegate?.recordStandupModel(self, didCancelMeetingWith: transcript)
            dismiss = true
        }
    }
    
    // MARK: Helpers
    
    @MainActor
    func task() async {
        do {
            let authorization = await speechClient.requestAuthorization()
            try await withThrowingTaskGroup(of: Void.self) { group in
                if authorization == .authorized {
                    group.addTask {
                        try await self.startSpeechRecognition()
                    }
                }
                
                group.addTask {
                    try await self.startTimer()
                }
                
                try await group.waitForAll()
            }
        } catch {
            destination = .alert(AlertState(title: TextState("Something went wrong.")))
        }
    }
    
    private func startSpeechRecognition() async throws {
        for try await result in await speechClient.startTask(SFSpeechAudioBufferRecognitionRequest()) {
            transcript = result.bestTranscription.formattedString
        }
    }
    
    private func startTimer() async throws {
        while !dismiss {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Should be an injectable dependency.
            guard destination == nil else { continue } // Pause while alert is up.
            secondsElapsed += 1
            if secondsElapsed.isMultiple(of: Int(standup.durationPerAttendee)) {
                if speakerIndex == standup.attendees.count - 1 {
                    delegate?.recordStandupModel(self, didFinishMeetingWith: transcript)
                    dismiss = true
                    break
                }
                
                speakerIndex += 1
            }
        }
    }
}
