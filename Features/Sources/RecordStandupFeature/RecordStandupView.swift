import SwiftUI
import SwiftUINavigation

// MARK: - RecordStandupView

public struct RecordStandupView: View {
    
    // MARK: Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var model: RecordStandupModel
    
    // MARK: Initializers
    
    public init(model: RecordStandupModel) {
        self.model = model
    }
    
    // MARK: Body
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(self.model.standup.theme.primaryColor)
            
            VStack {
                MeetingHeaderView(
                    secondsElapsed: model.secondsElapsed,
                    durationRemaining: model.durationRemaining,
                    theme: model.standup.theme
                )
                MeetingTimerView(
                    standup: model.standup,
                    speakerIndex: model.speakerIndex
                )
                MeetingFooterView(
                    standup: model.standup,
                    nextButtonTapped: { model.nextButtonTapped() },
                    speakerIndex: model.speakerIndex
                )
            }
        }
        .padding()
        .foregroundColor(model.standup.theme.accentColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("End meeting") { model.endMeetingButtonTapped() }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task { await model.task() }
        .onChange(of: model.dismiss) { _ in self.dismiss() }
        .alert(
            unwrapping: $model.destination,
            case: /RecordStandupModel.Destination.alert
        ) { action in
            model.alertButtonTapped(action)
        }
    }
}

// MARK: - RecordStandupView+Previews

struct RecordStandupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecordStandupView(
                model: RecordStandupModel(standup: .mock)
            )
        }
    }
}
