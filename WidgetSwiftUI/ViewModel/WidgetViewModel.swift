import SwiftUI

// MARK: - WidgetViewModel
/// ViewModel for managing the state and logic of the widget layout, including drag-and-drop insertion and preview.
class WidgetViewModel: ObservableObject {
    @Published var rootRect: DroppedWidget? = nil
    @Published var originalRect: DroppedWidget? = nil
    @Published var currentColor: Color = .gray
    @Published var highlightBlockId: UUID? = nil

    let colors: [Color] = [.skyBlue, .hotPink, .brightYellow, .limeGreen, .vibrantOrange]

    /// Resets the widget layout to its initial state.
    func reset() {
        rootRect = nil
        originalRect = nil
    }

    /// Performs the drop action by inserting a new block at the specified location and direction.
    func performDrop(color: Color, dropX: CGFloat, dropY: CGFloat, direction: SplitDirection) {
        if let original = originalRect {
            rootRect = insertWidgetAtDrop(
                node: original,
                color: color,
                dropX: dropX,
                dropY: dropY,
                split: direction
            )
        } else {
            rootRect = DroppedWidget(color: color, fraction: 1.0)
        }
    }

    /// Updates the preview layout and highlights the new block during drag-and-drop.
    func updatePreview(dropX: CGFloat, dropY: CGFloat, direction: SplitDirection) {
        if let original = originalRect {
            let preview = insertWidgetAtDrop(
                node: original,
                color: currentColor,
                dropX: dropX,
                dropY: dropY,
                split: direction
            )
            rootRect = preview
            if let newId = findNewBlockId(original: original, updated: preview, dropX: dropX, dropY: dropY) {
                highlightBlockId = newId
            }
        } else {
            let newBlock = DroppedWidget(color: currentColor, fraction: 1.0)
            rootRect = newBlock
            highlightBlockId = newBlock.id
        }
    }
}

// MARK: - Widget Alignment Helper
// Helper struct for managing rectangle alignment and insertion logic during drag-and-drop.
extension WidgetViewModel {
    /// Inserts a new rectangle (block) at the drop location within the given node tree.
    /// - Parameters:
    ///   - node: The root DroppedWidget node to insert into.
    ///   - color: The color of the new block to insert.
    ///   - dropX: The normalized x-coordinate (0...1) of the drop location.
    ///   - dropY: The normalized y-coordinate (0...1) of the drop location.
    ///   - split: The direction to split (vertical or horizontal) at this level.
    /// - Returns: An updated DroppedWidget tree with the new block inserted.
    func insertWidgetAtDrop(
        node: DroppedWidget,
        color: Color,
        dropX: CGFloat,
        dropY: CGFloat,
        split: SplitDirection
    ) -> DroppedWidget {
        // If the node has no children, split it into two blocks. The new one is at the drop location
        if node.children == nil {
            let first = DroppedWidget(color: node.color ?? .gray, fraction: 0.5)
            let second = DroppedWidget(color: color, fraction: 0.5)
            return DroppedWidget(
                fraction: node.fraction,
                split: split,
                children: (split == .vertical
                           ? (dropX < 0.5 ? [second, first] : [first, second])
                           : (dropY < 0.5 ? [second, first] : [first, second]))
            )
        }

        // If the node has children, try to insert a new block or recurse into the appropriate child up to 3 children
        if var children = node.children, let splitDir = node.split {
            // Determine orientation and calculate drop position and child start positions.
            let isVert = splitDir == .vertical
            let dropPos = isVert ? dropX : dropY
            let positions = children.scan(0) { $0 + $1.fraction }

            // Determine if we should split into 3 blocks based on drop position and current children count.
            let shouldSplitTo3: Bool
            if isVert {
                shouldSplitTo3 = (dropX > 0.33 && dropX < 0.67 || dropX < 0.1 || dropX > 0.9) && children.count == 2
            } else {
                shouldSplitTo3 = (dropY > 0.33 && dropY < 0.67 || dropY < 0.1 || dropY > 0.9) && children.count == 2
            }

            // If there is room to add a new block at this level (less than 3 children), insert it and rebalance fractions.
            if children.count < 3 && (children.count == 1 || shouldSplitTo3) {
                // Find the index where the new block should be inserted based on the drop position.
                var insertIdx = children.count // default to end
                for (i, start) in positions.enumerated() {
                    let center = start + children[i].fraction / 2
                    if dropPos < center {
                        insertIdx = i
                        break
                    }
                }

                // Insert a new block at the calculated index and rebalance all fractions equally
                let newChild = DroppedWidget(color: color, fraction: 0.0)
                children.insert(newChild, at: insertIdx)
                let newFrac = 1.0 / CGFloat(children.count)
                for i in 0..<children.count {
                    children[i].fraction = newFrac
                }

                // Return a new DroppedWidget with the inserted child and updated fractions
                return DroppedWidget(
                    fraction: node.fraction,
                    split: splitDir,
                    children: children
                )
            } else {
                // Otherwise, recurse into the closest child.

                // Find the child whose center is closest to the drop position to recurse into.
                var minDist: CGFloat = .greatestFiniteMagnitude
                var targetIdx = 0
                for (i, start) in positions.enumerated() {
                    let center = start + children[i].fraction / 2
                    let dist = abs(dropPos - center)
                    if dist < minDist {
                        minDist = dist
                        targetIdx = i
                    }
                }


                // This is a crucial part where we need to change the split direction: when there are three blocks with the same orientation, we convert them to one vertical and two horizontal (or vice versa).
                let nextSplit: SplitDirection = splitDir == .vertical ? .horizontal : .vertical
                let localDropX = isVert ? (dropX - positions[targetIdx]) / children[targetIdx].fraction : dropX
                let localDropY = !isVert ? (dropY - positions[targetIdx]) / children[targetIdx].fraction : dropY

                // Recurse into the closest child, converting the drop location to the child's local coordinate space
                children[targetIdx] = insertWidgetAtDrop(
                    node: children[targetIdx],
                    color: color,
                    dropX: localDropX,
                    dropY: localDropY,
                    split: nextSplit
                )

                // Return a new DroppedWidget with the updated child after recursion
                return DroppedWidget(
                    fraction: node.fraction,
                    split: splitDir,
                    children: children
                )
            }
        }
        return node
    }

    /// Finds the UUID of the new block inserted after a drop, by comparing the original and updated trees.
    /// - Parameters:
    ///   - original: The original DroppedWidget tree before the drop.
    ///   - updated: The updated DroppedWidget tree after the drop.
    ///   - dropX: The normalized x-coordinate (0...1) of the drop location.
    ///   - dropY: The normalized y-coordinate (0...1) of the drop location.
    /// - Returns: The UUID of the new block closest to the drop location, or nil if not found.
    func findNewBlockId(original: DroppedWidget, updated: DroppedWidget, dropX: CGFloat, dropY: CGFloat) -> UUID? {
        let originalIds = Set(flattenIds(node: original))
        let newLeaves = findAllNewLeaves(node: updated, originalIds: originalIds)
        if newLeaves.count == 1 { return newLeaves.first?.id }
        var minDist: CGFloat = .greatestFiniteMagnitude
        var targetId: UUID?
        for leaf in newLeaves {
            let dx = leaf.center.x - dropX
            let dy = leaf.center.y - dropY
            let dist = dx * dx + dy * dy
            if dist < minDist {
                minDist = dist
                targetId = leaf.id
            }
        }
        return targetId
    }

    /// Recursively finds all new leaf nodes (blocks) in the updated DroppedWidget tree that were not present in the original tree.
    /// - Parameters:
    ///   - node: The current DroppedWidget node to search.
    ///   - originalIds: The set of UUIDs from the original tree.
    ///   - frame: The CGRect representing the normalized bounds of the current node (default is the full area).
    /// - Returns: An array of LeafNode, each containing the id and center point of a new block.
    private func findAllNewLeaves(node: DroppedWidget, originalIds: Set<UUID>, frame: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> [LeafNode] {
        // If this is a leaf node (no children) and its id is not in the original tree, it's an only block.
        if node.children == nil && !originalIds.contains(node.id) {
            return [LeafNode(id: node.id, center: CGPoint(x: frame.midX, y: frame.midY))]
        }
        var result: [LeafNode] = []
        if let children = node.children, let split = node.split {
            // Recursively traverse children, updating the frame for each child based on the split direction.
            if split == .vertical {
                let widths = children.map { $0.fraction * frame.width }
                let xStarts = widths.scan(0, +)
                for (child, x) in zip(children, xStarts) {
                    let childFrame = CGRect(x: frame.minX + x, y: frame.minY, width: child.fraction * frame.width, height: frame.height)
                    result.append(contentsOf: findAllNewLeaves(node: child, originalIds: originalIds, frame: childFrame))
                }
            } else {
                let heights = children.map { $0.fraction * frame.height }
                let yStarts = heights.scan(0, +)
                for (child, y) in zip(children, yStarts) {
                    let childFrame = CGRect(x: frame.minX, y: frame.minY + y, width: frame.width, height: child.fraction * frame.height)
                    result.append(contentsOf: findAllNewLeaves(node: child, originalIds: originalIds, frame: childFrame))
                }
            }
        }
        return result
    }

    /// Recursively collects and flattens all `UUID` identifiers from the given `DroppedWidget` node and its descendants.
    ///
    /// - Parameter node: The root `DroppedWidget` node from which to start collecting IDs.
    /// - Returns: An array of `UUID` values representing the IDs of the node and all its children (recursively).
    private func flattenIds(node: DroppedWidget) -> [UUID] {
        var ids = [node.id]
        if let children = node.children {
            for child in children {
                ids.append(contentsOf: flattenIds(node: child))
            }
        }
        return ids
    }
}
