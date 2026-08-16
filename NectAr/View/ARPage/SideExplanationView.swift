//
//  SideExplanationView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 13/08/26.
//

import SwiftUI

/// Left-edge carousel listing the simulation as a sequence of explained steps. The top
/// card plays the full round trip, each step below loops just that one in isolation.
struct SideExplanationView: View {

    let controller: SimulationSceneController
    @State private var viewModel = ExpSimulationViewModel()

    var body: some View {
        @Bindable var controller = controller

        HStack(alignment: .top) {
            if viewModel.isListVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 45) {
                        ForEach(viewModel.cards) { card in
                            SimExplanationCard(title: card.title, description: card.description)
                                .opacity(viewModel.activeCardID == card.id ? 1.0 : 0.4)
                                .id(card.id)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        viewModel.setActiveCard(id: card.id)
                                    }
                                }
                        }
                    }
                    .padding(.leading)
                    .scrollTargetLayout()
                }
//                .frame(width: 350)
                .scrollPosition(id: $viewModel.activeCardID, anchor: .center)
                .contentMargins(.bottom, 400, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .transition(.move(edge: .leading).combined(with: .opacity))
                .onChange(of: viewModel.activeCardID) { _, newID in
                    guard let newID, let source = viewModel.source(for: newID) else { return }
                    switch source {
                    case .full: controller.select(.full)
                    case .step(let step): controller.select(.step(step))
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
            .padding(.leading)
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    SideExplanationView(controller: SimulationSceneController())
}
