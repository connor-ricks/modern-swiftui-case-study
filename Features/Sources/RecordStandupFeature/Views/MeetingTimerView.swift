import SwiftUI

import Models

// MARK: - MeetingTimerView

struct MeetingTimerView: View {
    
    // MARK: Properties
    
    let standup: Standup
    let speakerIndex: Int
    
    // MARK: Body
    
    var body: some View {
        Circle()
            .strokeBorder(lineWidth: 24)
            .overlay {
                VStack {
                    Text(currentSpeakerName)
                        .font(.title)
                    Text("is speaking")
                    Image(systemName: "mic.fill")
                        .font(.largeTitle)
                        .padding(.top)
                }
                .foregroundStyle(standup.theme.accentColor)
            }
            .overlay {
                ForEach(Array(standup.attendees.enumerated()), id: \.element.id) { index, attendee in
                    if index < speakerIndex + 1 {
                        SpeakerArc(totalSpeakers: standup.attendees.count, speakerIndex: index)
                            .rotation(Angle(degrees: -90))
                            .stroke(standup.theme.primaryColor, lineWidth: 12)
                    }
                }
            }
            .padding(.horizontal)
    }
    
    // MARK: Helpers
    
    private var currentSpeakerName: String {
        guard speakerIndex < standup.attendees.count else {
            return "Someone"
        }
        
        return standup.attendees[speakerIndex].name
    }
}

// MARK: - SpeakerArc

struct SpeakerArc: Shape {
    let totalSpeakers: Int
    let speakerIndex: Int
    
    private var degreesPerSpeaker: Double {
        360.0 / Double(totalSpeakers)
    }
    private var startAngle: Angle {
        Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1.0)
    }
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1.0)
    }
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
    }
}
