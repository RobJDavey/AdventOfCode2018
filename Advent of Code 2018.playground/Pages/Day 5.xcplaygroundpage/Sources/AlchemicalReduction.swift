import Foundation

public final class Polymer {
    var first: Unit
    
    init(first: Unit) {
        self.first = first
    }
    
    public convenience init(_ text: String) {
        var first: Unit? = nil
        var previous: Unit? = nil
        
        for character in text {
            let unit = Unit(character, previous: previous)
            
            if first == nil {
                first = unit
            }
            
            previous?.next = unit
            previous = unit
        }
        
        guard let u1 = first else {
            fatalError()
        }
        
        self.init(first: u1)
    }
}

extension Polymer {
    func remove(_ values: Character...) {
        var current: Unit? = first
        
        while current != nil {
            if values.contains(current!.value) {
                current?.previous?.next = current?.next
                current?.next?.previous = current?.previous
            }
            
            current = current?.next
        }
    }
    
    func clone() -> Polymer {
        var current: Unit? = first
        var previousClone: Unit?
        var firstClone: Unit?
        
        while (current != nil) {
            let clone = Unit(current!.value, previous: previousClone)
            
            if firstClone == nil {
                firstClone = clone
            }
            
            previousClone?.next = clone
            previousClone = clone
            current = current!.next
        }
        
        guard let unit = firstClone else {
            fatalError()
        }
        
        return Polymer(first: unit)
    }
    
    func length() -> Int {
        var current = first
        var total = 1
        
        while (current.next !== nil) {
            current = current.next!
            total += 1
        }
        
        return total
    }
    
    func react() {
        var current: Unit? = first
        var last = current
        
        while current != nil {
            if current!.canReactWithNext() {
                current = current?.reactWithNext()
            } else {
                current = current?.next
            }
            
            last = current ?? last
        }
        
        current = last
        
        while current?.previous != nil {
            current = current?.previous
        }
        
        self.first = current!
    }
}

final class Unit {
    let value: Character
    let reactsWith: Character
    
    weak var previous: Unit?
    var next: Unit?
    
    init(_ value: Character, previous: Unit?) {
        guard let scalarValue = value.unicodeScalars.first else {
            fatalError()
        }
        
        assert(scalarValue.isASCII)
        
        let v = scalarValue.value
        let u: UInt32
        
        if (65...90).contains(v) {
            u = v + 32
        } else {
            u = v - 32
        }
        
        guard let r = UnicodeScalar(u) else {
            fatalError()
        }
        
        self.value = value
        self.reactsWith = Character(r)
        self.previous = previous
        self.next = nil
    }
    
    func canReactWithNext() -> Bool {
        return next?.value == reactsWith
    }
    
    func reactWithNext() -> Unit? {
        let before = previous
        let after = next?.next
        
        before?.next = after
        after?.previous = before
        
        return before ?? after
    }
}

public func part1(_ polymer: Polymer) -> Int {
    let part1 = polymer.clone()
    part1.react()
    return part1.length()
}

public func part2(_ polymer: Polymer) -> Int {
    let range = 65...90
    var result = Int.max
    
    for value in range {
        let clone = polymer.clone()
        let upper = Character(UnicodeScalar(value)!)
        let lower = Character(UnicodeScalar(value + 32)!)
        clone.remove(upper, lower)
        clone.react()
        result = min(result, clone.length())
    }
    
    return result
}
