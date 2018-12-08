import Foundation

public typealias Step = Character
public typealias Dependencies = [Step : [Step]]
public typealias Worker = (step: Step, remaining: Int)?

public struct Instruction {
    let name: Step
    let dependency: Step
}

extension Instruction {
    public init(_ description: String) {
        let components = description.components(separatedBy: .whitespaces)
        dependency = components[1].first!
        name = components[7].first!
    }
}

public func parseDependencies(_ instructions: [Instruction]) -> Dependencies {
    let all = Set(instructions.map { $0.name }).union(Set(instructions.map { $0.dependency }))
    var group = Dictionary(grouping: instructions, by: { $0.name }).mapValues { $0.map { $0.dependency }}
    
    for key in all {
        guard let _ = group[key] else {
            group[key] = []
            continue
        }
    }
    
    return group
}

public func part1(_ dependencies: Dependencies) -> String {
    let all = Set(dependencies.keys)
    var completed: [Step] = []
    
    while !all.subtracting(completed).isEmpty {
        let remaining = all.subtracting(completed).sorted()
        let next = dependencies.filter { remaining.contains($0.key) }
            .filter { Set($0.value).subtracting(completed).isEmpty }
            .map { $0.key }
            .sorted()
            .first!
        completed.append(next)
    }
    
    return String(completed)
}

public func part2(_ dependencies: Dependencies, workerCount: Int, offset: Int) -> Int {
    func calculateTime(_ step: Step, offet: Int) -> Int {
        let scalar = step.unicodeScalars.first!
        assert(scalar.isASCII)
        return Int(scalar.value) - 64 + offet
    }
    
    let all = Set(dependencies.keys)
    var completed: [Step] = []
    var workers: [Worker] = Array(repeating: nil, count: workerCount)
    
    for t in 0... {
        let remaining = all.subtracting(completed).sorted()
        if remaining.isEmpty {
            return t - 1
        }
        
        let inProgress = workers.compactMap { $0?.step }
        
        for index in workers.startIndex..<workers.endIndex {
            if let worker = workers[index] {
                let newTime = worker.remaining - 1
                if newTime == 0 {
                    completed.append(worker.step)
                    workers[index] = nil
                } else {
                    workers[index] = (worker.step, newTime)
                }
            }
        }
        
        var available = dependencies.filter { remaining.contains($0.key) }
            .filter { Set($0.value).subtracting(completed).isEmpty }
            .filter { !inProgress.contains($0.key) }
            .map { $0.key }
            .sorted()
        
        for index in workers.startIndex..<workers.endIndex {
            let worker = workers[index]
            if worker == nil, !available.isEmpty {
                let next = available.removeFirst()
                let time = calculateTime(next, offet: offset)
                workers[index] = (next, time)
            }
        }
    }
    
    fatalError()
}
