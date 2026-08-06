import SwiftUI

struct PlacementActionButtonsView: View {
    let placementController: PlacementSceneController
    let onComplete: (PlacedTopology) -> Void

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 16) {
                Button {
                    if placementController.isComplete {
                        placementController.stopPreview()
                        onComplete(PlacedTopology(transforms: placementController.placedTransforms))
                    } else {
                        placementController.confirmPlacement()
                    }
                } label: {
                    Image(systemName: placementController.isComplete ? "play.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 32))
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }

                Button {
                    placementController.undoLastPlacement()
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 32))
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .disabled(!placementController.canUndo)
                .opacity(placementController.canUndo ? 1.0 : 0.4)
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
}
