import SwiftUI
import AppKit

struct SwitcherView: View {
    let apps: [NSRunningApplication]
    let hotAppBundleIDs: [String]
    @Binding var selectedIndex: Int

    private let iconSize: CGFloat = 64
    private let itemSpacing: CGFloat = 12
    private let padding: CGFloat = 16

    var body: some View {
        HStack(spacing: itemSpacing) {
            ForEach(Array(apps.enumerated()), id: \.element.processIdentifier) { index, app in
                AppIconView(
                    app: app,
                    isSelected: index == selectedIndex,
                    isHot: hotAppBundleIDs.contains(app.bundleIdentifier ?? ""),
                    iconSize: iconSize
                )
            }
        }
        .padding(padding)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct AppIconView: View {
    let app: NSRunningApplication
    let isSelected: Bool
    let isHot: Bool
    let iconSize: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(.secondary)
                }

                if isHot {
                    // Hot indicator
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                        .offset(x: iconSize / 2 - 5, y: -iconSize / 2 + 5)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
            )

            Text(app.localizedName ?? "Unknown")
                .font(.system(size: 11))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: iconSize + 16)
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
