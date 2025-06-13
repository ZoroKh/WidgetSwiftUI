import XCTest

@testable import WidgetSwiftUI

final class WidgetTests: XCTestCase {
    var widgetViewModel: WidgetViewModel!

    override func setUp() {
        super.setUp()
        widgetViewModel = WidgetViewModel()
    }

    override func tearDown() {
        widgetViewModel = nil
        super.tearDown()
    }

    func testInsertOnLeafCreatesSplit() {
        // Given: a single leaf node with one color
        let parent = DroppedWidget(color: .skyBlue, fraction: 1.0)

        // When: inserting a new color with a vertical split
        let result = widgetViewModel.insertWidgetAtDrop(
            node: parent,
            color: .hotPink,
            dropX: 0.2,
            dropY: 0.8,
            split: .vertical
        )

        // Then: expect a vertical split with two children, each color present
        XCTAssertNotNil(result.children)
        XCTAssertEqual(result.children?.count, 2)
        XCTAssertEqual(result.split, .vertical)
        XCTAssertTrue(result.children!.contains(where: { $0.color == .hotPink }))
        XCTAssertTrue(result.children!.contains(where: { $0.color == .skyBlue }))
    }

    func testInsertOnSplitAddsThirdChild() {
        // Given: a vertical split with two children
        let leaf1 = DroppedWidget(color: .skyBlue, fraction: 0.5)
        let leaf2 = DroppedWidget(color: .hotPink, fraction: 0.5)
        let parent = DroppedWidget(fraction: 1.0, split: .vertical, children: [leaf1, leaf2])

        // When: inserting a third color
        let result = widgetViewModel.insertWidgetAtDrop(
            node: parent,
            color: .brightYellow,
            dropX: 0.5,
            dropY: 0.5,
            split: .vertical
        )

        // Then: expect three children, all colors present, fractions equal
        XCTAssertNotNil(result.children)
        XCTAssertEqual(result.children?.count, 3)
        XCTAssertEqual(result.split, .vertical)
        XCTAssertTrue(result.children!.contains(where: { $0.color == .brightYellow }))
        let fractions = result.children!.map { $0.fraction }
        XCTAssertTrue(fractions.allSatisfy { abs($0 - (1.0/3.0)) < 0.001 })
    }

    func testInsertOnFullSplitGoesDeeper() {
        // Given: a vertical split with three children (full)
        let leaf1 = DroppedWidget(color: .skyBlue, fraction: 1/3)
        let leaf2 = DroppedWidget(color: .hotPink, fraction: 1/3)
        let leaf3 = DroppedWidget(color: .brightYellow, fraction: 1/3)
        let parent = DroppedWidget(fraction: 1.0, split: .vertical, children: [leaf1, leaf2, leaf3])

        // When: inserting a fourth color
        let result = widgetViewModel.insertWidgetAtDrop(
            node: parent,
            color: .limeGreen,
            dropX: 0.1,
            dropY: 0.5,
            split: .vertical
        )

        // Then: expect no new top-level child, but insertion goes deeper
        XCTAssertNotNil(result.children)
        XCTAssertEqual(result.children?.count, 3, "Should not add a 4th child, but go deeper")
        let firstChild = result.children!.first!
        if let nestedChildren = firstChild.children {
            XCTAssertTrue(nestedChildren.contains(where: { $0.color == .limeGreen }))
        } else {
            XCTFail("Expected nested children in first child")
        }
    }

    func testInsertOnLeafCreatesSplitHorizontally() {
        // Given: a single leaf node with one color
        let parent = DroppedWidget(color: .skyBlue, fraction: 1.0)

        // When: inserting a new color with a horizontal split
        let result = widgetViewModel.insertWidgetAtDrop(
            node: parent,
            color: .hotPink,
            dropX: 0.2,
            dropY: 0.8,
            split: .horizontal
        )

        // Then: expect a horizontal split with two children, each color present
        XCTAssertNotNil(result.children)
        XCTAssertEqual(result.children?.count, 2)
        XCTAssertEqual(result.split, .horizontal)
        XCTAssertTrue(result.children!.contains(where: { $0.color == .hotPink }))
        XCTAssertTrue(result.children!.contains(where: { $0.color == .skyBlue }))
    }

    func testInsertOnSplitAddsThirdChildHorizontally() {
        // Given: a horizontal split with two children
        let leaf1 = DroppedWidget(color: .skyBlue, fraction: 0.5)
        let leaf2 = DroppedWidget(color: .hotPink, fraction: 0.5)
        let parent = DroppedWidget(fraction: 1.0, split: .horizontal, children: [leaf1, leaf2])

        // When: inserting a third color
        let result = widgetViewModel.insertWidgetAtDrop(
            node: parent,
            color: .brightYellow,
            dropX: 0.5,
            dropY: 0.5,
            split: .horizontal
        )

        // Then: expect three children, all colors present, fractions equal
        XCTAssertNotNil(result.children)
        XCTAssertEqual(result.children?.count, 3)
        XCTAssertEqual(result.split, .horizontal)
        XCTAssertTrue(result.children!.contains(where: { $0.color == .brightYellow }))
        let fractions = result.children!.map { $0.fraction }
        XCTAssertTrue(fractions.allSatisfy { abs($0 - (1.0/3.0)) < 0.001 })
    }

    func testInsertOnFullSplitGoesDeeperHorizontally() {
        // Given: a horizontal split with three children (full)
        let leaf1 = DroppedWidget(color: .skyBlue, fraction: 1/3)
        let leaf2 = DroppedWidget(color: .hotPink, fraction: 1/3)
        let leaf3 = DroppedWidget(color: .brightYellow, fraction: 1/3)
        let parent = DroppedWidget(fraction: 1.0, split: .horizontal, children: [leaf1, leaf2, leaf3])

        // When: inserting a fourth color
        let result = widgetViewModel.insertWidgetAtDrop(
            node: parent,
            color: .limeGreen,
            dropX: 0.1,
            dropY: 0.2,
            split: .horizontal
        )

        // Then: expect no new top-level child, but insertion goes deeper
        XCTAssertNotNil(result.children)
        XCTAssertEqual(result.children?.count, 3, "Should not add a 4th child, but go deeper")
        let firstChild = result.children!.first!
        if let nestedChildren = firstChild.children {
            XCTAssertTrue(nestedChildren.contains(where: { $0.color == .limeGreen }))
        } else {
            XCTFail("Expected nested children in first child")
        }
    }
}
