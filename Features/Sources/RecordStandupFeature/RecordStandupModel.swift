import SwiftUI
import SwiftUINavigation
import Dependencies
import Speech

import Models

@MainActor
public class RecordStandupModel: ViewModel {
    
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

    let standup: Standup

    @Dependency(\.speechClient) var speechClient

    @Published var destination: Destination?
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var speakerIndex = 0

    public var onMeetingFinished: (String) -> Void = unimplemented("RecordStandupModel.onMeetingFinished")
    public var onDiscardMeeting: () -> Void = unimplemented("RecordStandupModel.onDiscardMeeting")

    private var transcript = ""
    private var timer: Timer? = nil

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
        guard speakerIndex < standup.attendees.count - 1 else {
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
            finishMeeting(discard: false)
        case .confirmDiscard:
            finishMeeting(discard: true)
        }
    }
    
    // MARK: Helpers

    func task() async {
        let authorization = await speechClient.requestAuthorization()
        if case .authorized = authorization {
            startSpeechRecognition()
        } else {
            destination = .alert(AlertState(title: TextState("No permissions for speach recognition.")))
        }

        startTimer()
    }
    
    private func startSpeechRecognition() {
        Task {
            do {
                for try await result in await speechClient.startTask(SFSpeechAudioBufferRecognitionRequest()) {
                    transcript = result.bestTranscription.formattedString
                }
            } catch {
                destination = .alert(AlertState(title: TextState("Something went wrong transcribing audio.")))
            }
        }
    }

    /// This is not a good example of code, just something quick to showcase a more complex task interaction and navigation.
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { @MainActor [weak self] timer in
            guard let self else { return }
            guard !self.isAlertOpen else { return }
            self.secondsElapsed += 1
            if self.secondsElapsed.isMultiple(of: Int(self.standup.durationPerAttendee)) {
                if self.speakerIndex == self.standup.attendees.count - 1 {
                    self.finishMeeting(discard: false)
                    return
                }

                self.speakerIndex += 1
            }
        }
    }

    private func finishMeeting(discard: Bool) {
        timer?.invalidate()
        timer = nil
        if discard {
            onDiscardMeeting()
        } else {
            onMeetingFinished(transcript)
        }
    }
}
