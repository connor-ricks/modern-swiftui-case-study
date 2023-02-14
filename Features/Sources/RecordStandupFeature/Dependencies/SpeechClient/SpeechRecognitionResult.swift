import Speech

struct SpeechRecognitionResult: Equatable {
    var bestTranscription: SpeechTranscription
    var isFinal: Bool
}

extension SpeechRecognitionResult {
    init(_ speechRecognitionResult: SFSpeechRecognitionResult) {
        self.bestTranscription = SpeechTranscription(speechRecognitionResult.bestTranscription)
        self.isFinal = speechRecognitionResult.isFinal
    }
}
