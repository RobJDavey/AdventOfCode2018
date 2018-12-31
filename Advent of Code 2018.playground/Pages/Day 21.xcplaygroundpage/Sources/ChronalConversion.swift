import Foundation

public let registerCount = 6

public func parse(_ description: String) -> (ip: Register, opcodes: [Opcode]) {
    var lines = description.components(separatedBy: .newlines)
    let ipLine = lines.removeFirst()
    let ipLineParts = ipLine.components(separatedBy: .whitespaces)
    
    guard ipLineParts.count == 2, ipLineParts[0] == "#ip", let ipRegister = Register(ipLineParts[1]) else {
        fatalError()
    }
    
    let opcodes = lines.map(Opcode.init)
    return (ipRegister, opcodes)
}

public func part1(ipIndex: Register, opcodes: [Opcode], registers: Registers = Array(repeating: 0, count: registerCount)) -> Int {
    precondition(registers.count == registerCount)
    var registers = registers
    var ip = 0
    
    while registers[ipIndex] < opcodes.count {
        if ip == 28 {
            return registers[2]
        }
        
        ip = registers[ipIndex]
        let opcode = opcodes[ip]
        opcode.perform(on: &registers)
        registers[ipIndex] += 1
    }
    
    fatalError()
}

public func part2(ipIndex: Register, opcodes: [Opcode], registers: Registers = Array(repeating: 0, count: registerCount)) -> Int {
    precondition(registers.count == registerCount)
    var registers = registers
    var ip = 0
    var seen: Set<Int> = []
    var seenArray: [Int] = []
    
    while registers[ipIndex] < opcodes.count {
        ip = registers[ipIndex]
        let opcode = opcodes[ip]
        opcode.perform(on: &registers)
        registers[ipIndex] += 1
        
        if ip == 28 {
            let r2 = registers[2]
            
            if seen.contains(r2) {
                let index = seenArray.index(seenArray.endIndex, offsetBy: -1)
                return seenArray[index]
            }
            
            seen.insert(r2)
            seenArray.append(r2)
        }
    }
    
    return registers[0]
}
