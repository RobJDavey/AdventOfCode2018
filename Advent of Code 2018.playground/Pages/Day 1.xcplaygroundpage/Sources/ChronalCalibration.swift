import Foundation

public func part1(_ items: Int...) -> Int {
    return part1(items)
}

public func part1(_ items: [Int]) -> Int {
    return items.reduce(0, +)
}

public func part2(_ items: Int...) -> Int {
    return part2(items)
}

public func part2(_ items: [Int]) -> Int {
    let infiniteItems = sequence(first: items.startIndex, next: { $0.advanced(by: 1) % items.count })
        .lazy
        .map { items[$0] }
    
    var answer2 = 0
    var history: Set<Int> = [0]
    
    for value in infiniteItems {
        answer2 += value
        
        if history.contains(answer2) {
            break
        }
        
        history.insert(answer2)
    }
    
    return answer2
}
