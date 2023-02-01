import Foundation
import Speech

struct SpeechTranscription: Equatable {
    var formattedString: String
}

extension SpeechTranscription {
    init(_ transcription: SFTranscription) {
        self.formattedString = transcription.formattedString
    }
}
