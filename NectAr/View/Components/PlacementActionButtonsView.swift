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
                        onComplete(PlacedTopology(transforms: placementController.placedTransforms))
                    } else {
                        placementController.confirmPlacement()
                    }
                } label: {
                    Image(systemName: placementController.isComplete ? "play.fill" : "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }

                Button {
                    placementController.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 32))
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
}
