import SwiftUI

struct DeviceSelectorView: View {
    let viewModel: PreparationViewModel
    private static let itemSize: CGFloat = 100

    var body: some View {
        VStack(spacing: 16) {
            ForEach(DeviceKind.allCases, id: \.self) { kind in
                let isPlaced = viewModel.placedKinds.contains(kind)

                Button {
                    viewModel.selectDevice(kind)
                } label: {
                    // The card artwork already contains the device label, so there's
                    // no separate Text here — see DeviceKind.icon.
                    Image(kind.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.itemSize)
                }
                .disabled(isPlaced)
                .opacity(isPlaced ? 0.5 : 1.0)
            }
        }
        .padding(.leading, 31)
    }
}
