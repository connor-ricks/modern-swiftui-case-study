import SwiftUI

import Models

public struct MeetingView: View {
    
    // MARK: Properties
    
    let meeting: Meeting
    let standup: Standup

    public init(meeting: Meeting, standup: Standup) {
        self.meeting = meeting
        self.standup = standup
    }
    
    // MARK: Body
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Divider()
                    .padding(.bottom)
                Text("Attendees")
                    .font(.headline)
                ForEach(standup.attendees) { attendee in
                    Text(attendee.name)
                }
                Text("Transcript")
                    .font(.headline)
                    .padding(.top)
                Text(meeting.transcript)
            }
        }
        .navigationTitle(Text(meeting.date, style: .date))
        .padding()
    }
}
