import SwiftUI

import Models

struct MeetingFooterView: View {
    
    // MARK: Properties
    
    let standup: Standup
    var nextButtonTapped: () -> Void
    let speakerIndex: Int
    
    // MARK: Body
    
    var body: some View {
        VStack {
            HStack {
                Text(speakerText)
                Spacer()
                Button(action: nextButtonTapped) {
                    Image(systemName: "forward.fill")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
    
    // MARK: Helpers
    
    private var speakerText: String {
        guard speakerIndex < standup.attendees.count - 1 else {
            return "No more speakers."
        }
        
        return "Speaker \(speakerIndex + 1) of \(standup.attendees.count)"
    }
}
