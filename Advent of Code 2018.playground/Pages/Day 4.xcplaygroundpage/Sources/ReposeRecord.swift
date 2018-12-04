import Foundation

func createCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}

let calendar = createCalendar()

public struct LogEntry {
    let timestamp: Date
    let entry: String
}

extension LogEntry {
    static let formatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd HH:mm"
        $0.timeZone = TimeZone.init(secondsFromGMT: 0)
        return $0
    }(DateFormatter())
    
    public init(_ text: String) {
        guard let timestampStartPreIndex = text.firstIndex(of: "["),
            let timestampEndIndex = text.firstIndex(of: "]") else {
                fatalError()
        }
        
        let timetampStartIndex = text.index(after: timestampStartPreIndex)
        let timestampText = String(text[timetampStartIndex..<timestampEndIndex])
        
        guard let timestamp = LogEntry.formatter.date(from: timestampText) else {
            fatalError()
        }
        
        let entryStartIndex = text.index(timestampEndIndex, offsetBy: 2)
        let entry = String(text[entryStartIndex...])
        
        self.init(timestamp: timestamp, entry: entry)
    }
}

extension LogEntry : CustomStringConvertible {
    public var description: String {
        let time = LogEntry.formatter.string(from: timestamp)
        return "[\(time)] \(entry)"
    }
}

extension LogEntry : Comparable {
    public static func < (lhs: LogEntry, rhs: LogEntry) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
}

public func getDurations(_ logEntries: [LogEntry]) -> [Int : [Int]] {
    func getMinuteEntries(start: Date, end: Date) -> [Int] {
        let startComponents = calendar.dateComponents([.minute], from: start)
        let startMinute = startComponents.minute!
        let durationComponents = calendar.dateComponents([.minute], from: start, to: end)
        let durationMinutes = durationComponents.minute!
        
        var result: [Int] = []
        
        for i in startMinute..<startMinute + durationMinutes {
            result.append(i % 60)
        }
        
        return result
    }
    
    var currentGuard: Int? = nil
    var lastSleepTime: Date? = nil
    var sleepTimes: [(id: Int, start: Date, end: Date)] = []
    
    guard let regex = try? NSRegularExpression(pattern: "\\d+", options: []) else {
        fatalError()
    }
    
    for logEntry in logEntries {
        switch logEntry.entry {
        case "wakes up":
            guard let guardID = currentGuard, let last = lastSleepTime else {
                fatalError()
            }
            
            sleepTimes.append((guardID, last, logEntry.timestamp))
            break
        case "falls asleep":
            lastSleepTime = logEntry.timestamp
            break
        default:
            let text = logEntry.entry
            let range = NSRange(location: 0, length: text.utf16.count)
            guard let match = regex.firstMatch(in: text, options: [], range: range) else {
                fatalError()
            }
            
            let startIndex = text.index(text.utf16.startIndex, offsetBy: match.range.location)
            let endIndex = text.index(text.utf16.startIndex, offsetBy: match.range.location + match.range.length)
            let guardIDText = text[startIndex..<endIndex]
            
            guard let guardID = Int(guardIDText) else {
                fatalError()
            }
            
            currentGuard = guardID
        }
    }
    
    return Dictionary(grouping: sleepTimes) { (id, start, end) in id }
        .mapValues { times in times.flatMap { getMinuteEntries(start: $0.start, end: $0.end) } }
}

public func part1(_ durations: [Int : [Int]]) -> Int {
    let durationsMax = durations.max { $0.value.count < $1.value.count }
    
    let d = Dictionary(grouping: durationsMax!.value, by: { $0 })
        .mapValues { $0.count }
        .max { $0.value < $1.value }
    
    guard let dm = durationsMax?.key, let min = d?.key else {
        fatalError()
    }
    
    return dm * min
}

public func part2(_ durations: [Int : [Int]]) -> Int {
    let maxGuardDuration = durations
        .mapValues({ times in
            Dictionary(grouping: times) { $0 }
                .mapValues { $0.count }
                .max { $0.value < $1.value }
        })
        .max(by: { a, b in a.value!.value < b.value!.value })
    
    guard let guardDuration = maxGuardDuration,
        let guardDurationData = guardDuration.value else {
        fatalError()
    }
    
    let guardID = guardDuration.key
    let minute = guardDurationData.key
    
    return guardID * minute
}
