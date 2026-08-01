//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = PlacementViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(session: viewModel.arSession)
                .ignoresSafeArea()

            Text(viewModel.hintText)
                .padding()
                .background(.black.opacity(0.6))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.top, 60)
        }
        .onAppear {
            viewModel.start()
        }
    }
}

#Preview {
    ContentView()
}
