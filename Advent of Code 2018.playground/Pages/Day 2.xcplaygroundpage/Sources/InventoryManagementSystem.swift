import Foundation

public func part1(_ lines: String...) -> Int {
    return part1(lines)
}

public func part1(_ lines: [String]) -> Int {
    func letterCount(_ text: String) -> [Character : Int] {
        return Dictionary(grouping: text) { $0 }
            .mapValues { $0.count }
    }

    let counts = lines.map(letterCount)
    let twoCount = counts.filter { $0.values.contains(where: { $0 == 2 }) }.count
    let threeCount = counts.filter { $0.values.contains(where: { $0 == 3 }) }.count
    return twoCount * threeCount
}

public func part2(_ lines: String...) -> String {
    return part2(lines)
}

public func part2(_ lines: [String]) -> String {
    func difference(_ lhs: String, _ rhs: String) -> (difference: String, count: Int) {
        precondition(lhs.count == rhs.count, "Can only calculate difference on strings of the same length")

        let difference = zip(lhs, rhs)
            .compactMap { (a, b) in a == b ? a : nil }

        return (String(difference), lhs.count - difference.count)
    }

    let differences = lines.enumerated()
        .lazy
        .map { (index, line) in (index.advanced(by: 1)..<lines.endIndex, line) }
        .map { (range, line) in (lines[range], line) }
        .flatMap { (sublines, line) in sublines.map { (line, $0) } }
        .map(difference)

    return differences.first { $0.count == 1 }!.difference
}
