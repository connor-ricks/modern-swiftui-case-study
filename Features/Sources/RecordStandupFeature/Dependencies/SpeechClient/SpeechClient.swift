import Speech
import Dependencies

// MARK: - SpeechClient

struct SpeechClient {
    var authorizationStatus: @Sendable () -> SFSpeechRecognizerAuthorizationStatus
    var requestAuthorization: @Sendable () async -> SFSpeechRecognizerAuthorizationStatus
    var startTask:
    @Sendable (SFSpeechAudioBufferRecognitionRequest) async -> AsyncThrowingStream<SpeechRecognitionResult, Error>
}

// MARK: - SpeechClient+Dependency

extension DependencyValues {
    var speechClient: SpeechClient {
        get { self[SpeechClient.self] }
        set { self[SpeechClient.self] = newValue }
    }
}

extension SpeechClient: DependencyKey {
    static var liveValue: SpeechClient {
        let speech = SpeechService()
        return SpeechClient(
            authorizationStatus: { SFSpeechRecognizer.authorizationStatus() },
            requestAuthorization: {
                await withUnsafeContinuation { continuation in
                    SFSpeechRecognizer.requestAuthorization { status in
                        continuation.resume(returning: status)
                    }
                }
            },
            startTask: { request in
                await speech.startTask(request: request)
            }
        )
    }
    
    static var previewValue: SpeechClient {
        let isRecording = LockIsolated(false)
        return Self(
            authorizationStatus: { .authorized },
            requestAuthorization: { .authorized },
            startTask: { _ in
                AsyncThrowingStream { continuation in
                    Task { @MainActor in
                        isRecording.setValue(true)
                        var finalText = """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
                        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
                        exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute \
                        irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla \
                        pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui \
                        officia deserunt mollit anim id est laborum.
                        """
                        var text = ""
                        while isRecording.value {
                            let word = finalText.prefix { $0 != " " }
                            try await Task.sleep(nanoseconds: UInt64(word.count * 50 + Int.random(in: 0...200000000))) 
                            finalText.removeFirst(word.count)
                            if finalText.first == " " {
                                finalText.removeFirst()
                            }
                            text += word + " "
                            continuation.yield(
                                SpeechRecognitionResult(
                                    bestTranscription: SpeechTranscription(
                                        formattedString: text
                                    ),
                                    isFinal: false
                                )
                            )
                        }
                    }
                }
            }
        )
    }
}
