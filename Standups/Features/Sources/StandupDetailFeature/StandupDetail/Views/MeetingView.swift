import SwiftUI

import Models

struct MeetingView: View {
    
    // MARK: Properties
    
    let meeting: Meeting
    let standup: Standup
    
    // MARK: Body
    
    var body: some View {
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
