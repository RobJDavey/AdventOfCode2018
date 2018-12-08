import Foundation

public struct Node {
    let children: [Node]
    let metadata: [Int]
}

extension Node {
    public init(_ items: [String]) {
        let numbers = items.compactMap(Int.init)
        self.init(numbers)
    }
    
    init(_ items: [Int]) {
        var index = items.startIndex
        self.init(items, index: &index)
    }
    
    init(_ items: [Int], index: inout Array<Int>.Index) {
        func readNext<T>(_ items: [T], index: inout Array<T>.Index) -> T {
            let item = items[index]
            index += 1
            return item
        }
        
        let childNodeQuantity = readNext(items, index: &index)
        let metadataQuantity = readNext(items, index: &index)
        
        var childNodes: [Node] = []
        
        for _ in 0..<childNodeQuantity {
            let childNode = Node(items, index: &index)
            childNodes.append(childNode)
        }
        
        var metadata: [Int] = []
        
        for _ in 0..<metadataQuantity {
            let metadataItem = readNext(items, index: &index)
            metadata.append(metadataItem)
        }
        
        self.children = childNodes
        self.metadata = metadata
    }
    
    public func part1() -> Int {
        let childValue = children.map { $0.part1() }.reduce(0, +)
        let metadataValue = metadata.reduce(0, +)
        return childValue + metadataValue
    }
    
    public func part2() -> Int {
        if children.isEmpty {
            return metadata.reduce(0, +)
        }
        
        var items: [Int] = []
        
        for metadataItem in metadata {
            let index = children.index(before: metadataItem)
            if index >= children.startIndex && index < children.endIndex {
                let child = children[index]
                let childValue = child.part2()
                items.append(childValue)
            }
        }
        
        return items.reduce(0, +)
    }
}
