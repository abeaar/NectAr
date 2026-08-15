import SwiftUI

struct DeviceSelectorView: View {
    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel
    private static let itemSize: CGFloat = 100

    var body: some View {
        VStack(spacing: 16) {
            ForEach(DeviceKind.allCases, id: \.self) { kind in
                let isPlaced = placementViewModel.placedKinds.contains(kind)

                Button {
                    guard !mascotViewModel.isActive else { return }
                    placementViewModel.selectDevice(kind)
                } label: {
                    Image(kind.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.itemSize)
                }
                .disabled(isPlaced)
                .opacity(isPlaced ? 0.5 : 1.0)
                .overlay {
                    if isPlaced {
                        Image(kind.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Self.itemSize)
                            .colorMultiply(.orange)
                            .opacity(0.5)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .padding(.leading, 31)
    }
}

#Preview {
    DeviceSelectorView(
        placementViewModel: PlacementViewModel(),
        mascotViewModel: MascotViewModel()
    )
}
