import SwiftUI

struct DeviceSelectorView: View {
    let controller: PlacementSceneController
    private static let itemSize: CGFloat = 97

    var body: some View {
        VStack(spacing: 35) {
            ForEach(DeviceKind.allCases, id: \.self) { kind in
                let isPlaced = controller.placedKinds.contains(kind)

                Button {
                    controller.selectedDeviceKind = kind
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isPlaced ? "checkmark.circle.fill" : kind.icon)
                            .font(.title2)
                        Text(kind.label)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(width: Self.itemSize, height: Self.itemSize)
                    .background(
                        controller.selectedDeviceKind == kind
                            ? Color.accentColor.opacity(0.4)
                            : Color.black.opacity(0.4)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isPlaced)
                .opacity(isPlaced ? 0.4 : 1.0)
            }
        }
        .padding(.leading, 31)
    }
}
