import Foundation
import SwiftUI

struct DelayColors {
    static let onTime = Color(red: 0x10/255, green: 0xB9/255, blue: 0x81/255)
    static let slight = Color(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255)
    static let moderate = Color(red: 0xF9/255, green: 0x73/255, blue: 0x16/255)
    static let delayed = Color(red: 0xEF/255, green: 0x44/255, blue: 0x44/255)
    static let severe = Color(red: 0x7F/255, green: 0x1D/255, blue: 0x1D/255)
    
    static func colorForDelay(minutes: Int) -> Color {
        switch minutes {
        case 0...4:
            return onTime
        case 5...14:
            return slight
        case 15...20:
            return moderate
        case 21...60:
            return delayed
        default:
            return severe
        }
    }
    
    static func colorHexForDelay(minutes: Int) -> String {
        switch minutes {
        case 0...4:
            return "#10B981"
        case 5...14:
            return "#F59E0B"
        case 15...20:
            return "#F97316"
        case 21...60:
            return "#EF4444"
        default:
            return "#7F1D1D"
        }
    }
}

struct TrainTypeHelper {
    static func icon(for mode: String?) -> String {
        switch mode?.uppercased() {
        case "RAIL":
            return "lightrail"
        case "TRAM":
            return "tram"
        case "SUBURBAN_RAILWAY":
            return "lightrail"
        case "TRAMTRAIN":
            return "lightrail"
        default:
            return "questionmark.circle"
        }
    }
    
    static func displayName(for mode: String?) -> String {
        switch mode?.uppercased() {
        case "RAIL":
            return "Train"
        case "TRAM":
            return "Tram"
        case "SUBURBAN_RAILWAY":
            return "Suburban"
        case "TRAMTRAIN":
            return "Tram-Train"
        default:
            return "Vehicle"
        }
    }
}

struct TimeFormatHelper {
    static func formatSecondsSinceMidnight(_ seconds: Int64) -> String {
        let hours = Int(seconds / 3600) % 24
        let minutes = Int((seconds % 3600) / 60)
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    static func formatDelay(seconds: Int64?) -> String {
        guard let seconds = seconds, seconds != 0 else {
            return "On time"
        }
        
        let minutes = Int(seconds / 60)
        if minutes == 0 {
            return "On time"
        } else if minutes > 0 {
            return "+\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    static func getCurrentDelay(stoptimes: [Stoptimes], nowSeconds: Int64) -> Int64 {
        for stop in stoptimes {
            if stop.realtimeArrival > nowSeconds {
                return stop.arrivalDelay ?? stop.departureDelay ?? 0
            }
        }
        if let lastStop = stoptimes.last {
            return lastStop.arrivalDelay ?? lastStop.departureDelay ?? 0
        }
        return 0
    }
    
    static func getNowInSeconds() -> Int64 {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute, .second], from: now)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        return Int64(hours * 3600 + minutes * 60 + seconds)
    }
}

struct UICFormatter {
    static func format(vehicleId: String) -> String {
        let parts = vehicleId.split(separator: ":").map(String.init)
        guard parts.count >= 2 else { return vehicleId }
        
        let id = parts[1]
        
        let pattern = "^(\\d{2})(\\d{2})(\\d{4})(\\d{3})(\\d)$"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: id, range: NSRange(id.startIndex..., in: id)) {
            let ranges = (1..<match.numberOfRanges).compactMap { i -> String? in
                guard let range = Range(match.range(at: i), in: id) else { return nil }
                return String(id[range])
            }
            if ranges.count == 5 {
                return "\(ranges[0]) \(ranges[1]) \(ranges[2]) \(ranges[3])-\(ranges[4])"
            }
        }
        
        return id
    }
}
