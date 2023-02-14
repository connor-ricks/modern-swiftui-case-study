import SwiftUI

import Models

// MARK: - MeetingHeaderView

struct MeetingHeaderView: View {
    
    // MARK: Properties
    
    let secondsElapsed: Int
    let durationRemaining: TimeInterval
    let theme: StandupTheme
    
    // MARK: Body
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(MeetingProgressViewStyle(theme: self.theme))
            HStack {
                VStack(alignment: .leading) {
                    Text("Seconds Elapsed")
                        .font(.caption)
                    Label("\(Int(secondsElapsed))", systemImage: "hourglass.bottomhalf.fill")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Seconds Remaining")
                        .font(.caption)
                    Label("\(Int(durationRemaining))", systemImage: "hourglass.tophalf.fill")
                        .font(.body.monospacedDigit())
                }
            }
        }
        .padding([.top, .horizontal])
    }
    
    // MARK: Helpers
    
    private var totalDuration: TimeInterval {
        TimeInterval(secondsElapsed) + durationRemaining
    }
    
    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return TimeInterval(secondsElapsed) / TimeInterval(totalDuration)
    }
}

// MARK: - MeetingProgressViewStyle

private struct MeetingProgressViewStyle: ProgressViewStyle {
    var theme: StandupTheme
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(theme.accentColor)
                .frame(height: 20.0)
            
            ProgressView(configuration)
                .tint(theme.primaryColor)
                .frame(height: 12.0)
                .padding(.horizontal)
        }
    }
}
