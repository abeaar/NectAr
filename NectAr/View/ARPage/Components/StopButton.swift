import SwiftUI

struct StopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("StopButton2")
        }
        .accessibilityLabel(Text("Stop Simulation Button"))
    }
}
