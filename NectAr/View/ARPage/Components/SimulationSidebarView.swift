import SwiftUI

/// Left-edge carousel listing the simulation as a sequence of explained steps. The top
/// card plays the full round trip, each step below loops just that one in isolation.
struct SimulationSidebarView: View {
    let controller: SimulationSceneController
    @State private var isListVisible = true
    @State private var focusedID: String?

    private struct Item: Identifiable {
        enum Source { case full, step(SimulationStepKind) }
        let id: String
        let source: Source
        let title: String
        let explanation: String
    }

    private var items: [Item] {
        var list: [Item] = [
            .init(id: "full", source: .full,
                  title: SimulationFullCard.default.title,
                  explanation: SimulationFullCard.default.explanation)
        ]
        list.append(contentsOf: SimulationStepKind.allCases.map { step in
            .init(id: "step.\(step.title)", source: .step(step),
                  title: step.title, explanation: step.explanation)
        })
        return list
    }

    private var activeID: String {
        switch controller.selection {
        case .full: "full"
        case .step(let step): "step.\(step.title)"
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            if isListVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(items) { item in
                            card(for: item)
                        }
                    }
                    .padding(.leading, 30)
                    .scrollTargetLayout()
                }
                .frame(width: 350)
                .scrollPosition(id: Binding(
                    get: { focusedID ?? activeID },
                    set: { focusedID = $0 }
                ), anchor: .center)
                .contentMargins(.bottom, 700, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            Button {
                withAnimation(.easeInOut) {
                    isListVisible.toggle()
                }
            } label: {
                Image("LibraryButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64)
            }
            .padding(.leading, 20)
            .padding(.top, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func select(_ source: Item.Source) {
        switch source {
        case .full: controller.select(.full)
        case .step(let step): controller.select(.step(step))
        }
    }

    @ViewBuilder
    private func card(for item: Item) -> some View {
        ExplanationCard(title: item.title, description: item.explanation)
            .opacity((focusedID ?? activeID) == item.id ? 1.0 : 0.4)
            .id(item.id)
            .onTapGesture {
                focusedID = item.id
                select(item.source)
            }
    }
}

#Preview {
    SimulationSidebarView(controller: SimulationSceneController())
}
