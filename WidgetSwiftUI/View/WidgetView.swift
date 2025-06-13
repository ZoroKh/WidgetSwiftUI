import SwiftUI

// MARK: - Main Widget View
// This view provides the main UI for the widget drag-and-drop playground.
// It includes a reset button, a drop area for widgets, and a color palette for creating new draggable widgets.
struct WidgetView: View {
    @StateObject private var widgetVM = WidgetViewModel()

    var body: some View {
        VStack {
            Spacer()

            // Reset button to clear the drop area and remove all widgets
            HStack {
                Spacer()
                Button(action: {
                    widgetVM.reset()
                }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
                        )
                }
                .padding(.trailing, 32)
            }

            Spacer()

            // Main drop area for widgets.
            // - Shows a placeholder when empty.
            // - Renders dropped rectangles using `renderRects` when not empty.
            // - Handles drag-and-drop via `DropWidgetDelegate`.
            GeometryReader { geo in
                ZStack {
                    if widgetVM.rootRect == nil {
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(style: StrokeStyle(lineWidth: 3, dash: [8]))
                            .foregroundColor(.gray.opacity(0.15))
                            .background(
                                RoundedRectangle(cornerRadius: 36)
                                    .fill(Color.white)
                                    .opacity(0.15)
                            )
                        VStack(spacing: 16) {
                            Text("👋")
                                .font(.system(size: 48))

                            Text("Hi!")
                                .bold()
                                .foregroundColor(.gray)
                                .font(.headline)

                            Text("Drag and drop your widgets to unleash your creativity!")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .font(.headline)
                        }
                    } else if let rootRect = widgetVM.rootRect {
                        renderRects(rootRect, in: CGRect(origin: .zero, size: geo.size), highlightId: widgetVM.highlightBlockId)
                    }
                }
                .onDrop(of: [.utf8PlainText], delegate: DropWidgetDelegate(
                    widgetVM: widgetVM,
                    geoSize: geo.size
                ))
            }
            .frame(height: 400)
            .padding(.horizontal, 20)
            .padding(.bottom, 60)

            Spacer()

            // Color palette for draggable widget creation.
            // - Each circle represents a color users can drag into the drop area.
            // - Dragging sets `currentColor` and provides a drag preview.
            HStack(spacing: 20) {
                ForEach(widgetVM.colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 50)
                        .contentShape(.dragPreview, Circle())
                        .onDrag({
                            widgetVM.currentColor = color
                            return NSItemProvider(object: color.name as NSString)
                        }, preview: {
                            Circle()
                                .fill(color)
                                .frame(width: 50)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 2) // Visual feedback
                        })
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 2)
            )
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }

    // MARK: - Rectangle Rendering, Highlight & Block Identification Helpers
    /// Recursively renders a tree of `DroppedWidget` nodes as nested rectangles within a given frame.
    /// - Parameters:
    ///   - node: The root `DroppedWidget` node to render. Each node may have children and a split direction.
    ///   - frame: The `CGRect` specifying the area in which to render the current node and its children.
    ///   - highlightId: An optional `UUID` used to highlight a specific node while dropping by applying a shadow effect.
    /// - Returns: A SwiftUI `View` representing the rendered rectangles, split vertically or horizontally according to the node's split type and fractions. Leaf nodes are rendered as rounded rectangles with a highlighting on the dragging rectangle
    @ViewBuilder
    private func renderRects(_ node: DroppedWidget, in frame: CGRect, highlightId: UUID? = nil) -> some View {
        // Recursively render children if the node is split (either vertically or horizontally).
        // For vertical splits, divide the frame into columns; for horizontal splits, into rows.
        // Each child is rendered in its calculated sub-rectangle.
        if let children = node.children, let split = node.split {
            if split == .vertical {
                let widths = children.map { $0.fraction * frame.width }
                let xStarts = widths.scan(0, +)
                AnyView(
                    ForEach(Array(zip(children, xStarts)), id: \.0.id) { (child, x) in
                        renderRects(child, in: CGRect(x: frame.minX + x, y: frame.minY, width: child.fraction * frame.width, height: frame.height), highlightId: highlightId)
                    }
                )
            } else {
                let heights = children.map { $0.fraction * frame.height }
                let yStarts = heights.scan(0, +)
                AnyView(
                    ForEach(Array(zip(children, yStarts)), id: \.0.id) { (child, y) in
                        renderRects(child, in: CGRect(x: frame.minX, y: frame.minY + y, width: frame.width, height: child.fraction * frame.height), highlightId: highlightId)
                    }
                )
            }
        }
        // Render a leaf node as a rounded rectangle with its assigned color.
        // If this node is being dragged, apply a shadow effect.
        else if let color = node.color {
            RoundedRectangle(cornerRadius: 36)
                .fill(color)
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.midX, y: frame.midY)
                .shadow(color: (highlightId == node.id ? .black.opacity(0.5) : .clear), radius: (highlightId == node.id ? 10 : 0), x: 0, y: 2)
                .animation(.spring(duration: 0.3), value: node)
        }
    }
}

#Preview {
    WidgetView()
}
