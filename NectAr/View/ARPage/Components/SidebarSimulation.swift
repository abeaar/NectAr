//
//  SideExplanationView.swift
//  NectAr
//

import SwiftUI

/// Left-edge carousel listing the simulation as a situational sequence of explained
/// steps. On a failure, the list truncates to the prefix that actually played and
/// ends in a failure card. During the first loop the active card mirrors the
/// controller's own narrated timeline and taps are ignored. Once the second loop
/// starts, after the quiz prompt is declined, every card is tappable and plays its
/// own animation, with "Introduction" replaced by "Full Simulation".
struct SidebarSimulation: View {

    let controller: SimulationSceneController
    @State private var viewModel = ExpSimulationViewModel()

    var body: some View {
        @Bindable var controller = controller

        HStack(alignment: .top) {
            if viewModel.isListVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(viewModel.cards(failureReason: controller.failureReason, sendToRouterObstructed: controller.sendToRouterObstructed, sendToTargetObstructed: controller.sendToTargetObstructed, isSecondLoop: controller.loopMode == .manual)) { card in
                            SimExplanationCard(title: card.title, description: card.description)
                                .opacity(viewModel.activeCardID == card.id ? 1.0 : 0.3)
                                .id(card.id)
                                .onTapGesture {
                                    guard controller.loopMode == .manual else { return }
                                    withAnimation(.easeInOut) {
                                        viewModel.setActiveCard(id: card.id)
                                    }
                                    if let selection = viewModel.playbackSelection(for: card) {
                                        controller.select(selection)
                                    }
                                }
                        }
                    }
                    .padding(.leading, 30)
                    .scrollTargetLayout()
                }
                .frame(width: 350)
                .scrollPosition(id: $viewModel.activeCardID, anchor: .top)
                .contentMargins(.top, 16, for: .scrollContent)
                .contentMargins(.bottom, 700, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .transition(.move(edge: .leading).combined(with: .opacity))
                .onChange(of: controller.activeCardID) { _, newCard in
                    guard let newCard,
                          let cardID = viewModel.cardID(for: newCard, failureReason: controller.failureReason) else { return }
                    withAnimation(.easeInOut) {
                        viewModel.setActiveCard(id: cardID)
                    }
                }
            }

            Button {
                withAnimation(.easeInOut) {
                    viewModel.toggleVisibility()
                }
            } label: {
                Image("LibraryButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44)
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    SidebarSimulation(controller: SimulationSceneController())
}
