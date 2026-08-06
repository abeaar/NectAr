import SwiftUI

struct DeviceSelectorView: View {
    let controller: PlacementSceneController

    var body: some View {
        // temporary
        HStack(spacing: 16) {
            ForEach(DeviceKind.allCases, id: \.self) { kind in
                let isPlaced = controller.placedKinds.contains(kind)

                Button {
                    controller.selectedDeviceKind = kind
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isPlaced ? "plus.circle.fill" : kind.icon)
                            .font(.title2)
                        Text(kind.label)
                            .font(.caption)
                    }
                    .padding(10)
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
        .padding()
    }
}
