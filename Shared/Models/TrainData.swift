import Foundation

struct Holavonat: Codable {
    let source: Source
    let timestamp: String
    let vehiclePositions: [VehiclePositions]
    let lastUpdated: Int64
}

struct VehiclePositions: Codable, Identifiable, Hashable, Equatable {
    let stopRelationship: StopRelationship?
    let vehicleId: String
    let label: String?
    let trip: Trip
    let lat: Double
    let lon: Double
    let heading: Double?
    let lastUpdated: Int?
    let speed: Double?
    let nextStop: NextStop?

    var id: String {
        vehicleId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(vehicleId)
    }

    static func == (lhs: VehiclePositions, rhs: VehiclePositions) -> Bool {
        lhs.vehicleId == rhs.vehicleId
    }
}

struct StopRelationship: Codable, Hashable, Equatable {
    let status: String?
    let stop: Stop?
}

struct Trip: Codable, Hashable, Equatable {
    let route: Route
    let tripGeometry: TripGeometry?
    let wheelchairAccessible: String?
    let tripHeadsign: String?
    let tripShortName: String?
    let domesticResTrainNumber: String?
    let routeShortName: String?
    let bikesAllowed: String?
    let pattern: Pattern?
    let tripNumber: String?
    let gtfsId: String?
    let trainCategoryId: String?
    let id: String?
    let infoServices: [InfoService]?
    let stoptimes: [Stoptimes]
    let alerts: [Alerts]?
    let arrivalStoptime: ArrivalStoptime?
    let trainCategoryBaseId: Int64?
}

struct Route: Codable, Hashable, Equatable {
    let mode: String?
    let shortName: String?
    let longName: String?
    let textColor: String?
    let color: String?
}

struct TripGeometry: Codable, Hashable, Equatable {
    let points: String?
    let length: Int?
}

struct Stop: Codable, Hashable, Equatable {
    let name: String
    let platformCode: String?
    let lat: Double
    let lon: Double
}

struct Stoptimes: Codable, Hashable, Equatable {
    let stop: Stop
    let realtimeArrival: Int64
    let realtimeDeparture: Int64
    let arrivalDelay: Int64?
    let departureDelay: Int64?
    let scheduledArrival: Int64
    let scheduledDeparture: Int64
}

struct NextStop: Codable, Hashable, Equatable {
    let arrivalDelay: Int64
}

struct ArrivalStoptime: Codable, Hashable, Equatable {
    let arrivalDelay: Int64?
}

struct InfoService: Codable, Hashable, Equatable {
    let name: String?
    let fontCharSet: String?
    let fromStopIndex: Int?
    let tillStopIndex: Int?
    let fontCode: Int?
    let displayable: Bool?
}

struct Alerts: Codable, Hashable, Equatable {
    let alertUrl: AnyCodable?
    let id: String
    let feed: String
    let alertHeaderText: String
    let alertDescriptionText: String
    let alertCause: String?
    let alertSeverityLevel: String?
    let alertEffect: String?
    let alertHash: Int?
    let effectiveEndDate: Int?
    let effectiveStartDate: Int?
}

struct Pattern: Codable, Hashable, Equatable {
    let id: String?
}

struct Source: Codable, Hashable, Equatable {
    let origin: String?
    let latest: String?
    let directLink: String?
    let schema: Schema?
}

struct Schema: Codable, Hashable, Equatable {
    let version: String?
    let link: String?
    let format: String?
}

enum AnyCodable: Codable, Hashable, Equatable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([AnyCodable])
    case object([String: AnyCodable])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: AnyCodable].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case let .bool(bool):
            try container.encode(bool)
        case let .int(int):
            try container.encode(int)
        case let .double(double):
            try container.encode(double)
        case let .string(string):
            try container.encode(string)
        case let .array(array):
            try container.encode(array)
        case let .object(object):
            try container.encode(object)
        }
    }
}
