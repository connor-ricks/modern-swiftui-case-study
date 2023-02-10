import SwiftUI

import Models

struct CardView: View {
    
    // MARK: Properties
    
    let standup: Standup
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(standup.title)
                .font(.headline)
            Spacer()
            HStack {
                Label("\(standup.attendees.count)", systemImage: "person.3")
                Spacer()
                Label("\(Int(standup.duration))", systemImage: "clock")
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(self.standup.theme.accentColor)
    }
}
