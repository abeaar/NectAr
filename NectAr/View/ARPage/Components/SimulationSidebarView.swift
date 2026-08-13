import SwiftUI

/// Left-edge panel listing the simulation as a sequence of explained steps. The
/// top card plays the full round trip; each step below it loops just that one
/// step in isolation so the user can inspect it on its own.
struct SimulationSidebarView: View {
    let controller: SimulationSceneController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                stepCard(
                    title: "Full Simulation",
                    explanation: "Plays the complete round trip between both devices.",
                    status: controller.deadzoneHint,
                    isSelected: controller.selection == .full
                ) {
                    controller.select(.full)
                }

                ForEach(SimulationStepKind.allCases) { step in
                    stepCard(
                        title: step.title,
                        explanation: step.explanation,
                        status: controller.selection == .step(step) ? controller.stepStatusText : nil,
                        isSelected: controller.selection == .step(step)
                    ) {
                        controller.select(.step(step))
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 260)
        .background(.black.opacity(0.6))
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private func stepCard(title: String, explanation: String, status: String?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text(explanation)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                if let status {
                    Text(status)
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? .white.opacity(0.25) : .white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
