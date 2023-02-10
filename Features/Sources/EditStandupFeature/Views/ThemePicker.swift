import SwiftUI

import Models

struct ThemePicker: View {
    
    // MARK: Properties
    
    @Binding var selection: StandupTheme
    
    // MARK: Body
    
    var body: some View {
        Picker("Theme", selection: $selection) {
            ForEach(StandupTheme.allCases) { theme in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.primaryColor)
                    Label(theme.name, systemImage: "paintpalette")
                        .padding(4)
                }
                .foregroundColor(theme.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .tag(theme)
            }
        }
    }
}
