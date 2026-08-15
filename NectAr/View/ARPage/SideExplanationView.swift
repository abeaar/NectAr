//
//  SideExplanationView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 13/08/26.
//

import SwiftUI

struct ExplanationView: View {
    
    @State private var viewModel = ExpSimulationViewModel()
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isListVisible {
                    ScrollView(.vertical, showsIndicators: false){
                        VStack(spacing: 14) {
                            ForEach(viewModel.cards) { card in
                                ExplanationCard(title: card.title, description: card.description)
                                    .opacity(viewModel.activeCardID == card.id ? 1.0 : 0.4)
                                    .id(card.id)
                                    .onTapGesture {
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
                }
            }
            
            Button(action: {
                withAnimation(.easeInOut) {
                    viewModel.toggleVisibility()
                }
            }) {
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
}

#Preview {
    ExplanationView()
}
