//
//  SideExplanationView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 13/08/26.
//

import SwiftUI

/// Left-edge carousel listing the simulation as a sequence of explained steps. The top
/// card plays the full round trip, each step below loops just that one in isolation.
struct SidebarSimulation: View {

    let controller: SimulationSceneController
    @State private var viewModel = ExpSimulationViewModel()

    var body: some View {
        @Bindable var controller = controller

        HStack(alignment: .top) {
            if viewModel.isListVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(viewModel.cards) { card in
                            SimExplanationCard(title: card.title, description: card.description)
                                .opacity(viewModel.activeCardID == card.id ? 1.0 : 0.3)
                                .id(card.id)
                                .onTapGesture {
                                    guard !controller.phaseSequenceActive else { return }
                                    withAnimation(.easeInOut) {
                                        viewModel.setActiveCard(id: card.id)
                                    }
                                }
                        }
                    }
                    .padding(.leading, 30)
                    .scrollTargetLayout()
                }
                .frame(width: 350)
                .scrollPosition(id: $viewModel.activeCardID, anchor: .center)
                .contentMargins(.bottom, 700, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .transition(.move(edge: .leading).combined(with: .opacity))
                .onChange(of: controller.currentPhase) { _, newPhase in
                    guard let newPhase,
                          let cardID = viewModel.cardID(forStep: newPhase) else { return }
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
            .padding(.leading, 20)
            .padding(.top, 10)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    SidebarSimulation(controller: SimulationSceneController())
}
