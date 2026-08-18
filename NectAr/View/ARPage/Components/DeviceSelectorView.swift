import SwiftUI

struct DeviceSelectorView: View {
    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel
    /// Kinds selectable right now, nil means no restriction.
    var restrictedTo: Set<DeviceKind>? = nil
    /// Pulses a highlight ring around just the Router icon, not the whole list.
    var highlightRouterOnly = false
    /// Pulses a highlight ring around the whole list.
    var isListHighlighted = false
    private static let itemSize: CGFloat = 100

    var body: some View {
        VStack(spacing: 16) {
            ForEach(DeviceKind.allCases, id: \.self) { kind in
                let isPlaced = placementViewModel.placedKinds.contains(kind)
                let isRestricted = restrictedTo.map { !$0.contains(kind) } ?? false

                Button {
                    guard !mascotViewModel.isActive else { return }
                    placementViewModel.selectDevice(kind)
                } label: {
                    Image(kind.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.itemSize)
                }
                .disabled(isPlaced || isRestricted)
                .opacity((isPlaced || isRestricted) ? 0.5 : 1.0)
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
                .explanationHighlight(isActive: highlightRouterOnly && kind == .router)
            }
        }
        .explanationHighlight(isActive: isListHighlighted)
        .padding(.leading, 31)
    }
}

#Preview {
    DeviceSelectorView(
        placementViewModel: PlacementViewModel(),
        mascotViewModel: MascotViewModel()
    )
}
