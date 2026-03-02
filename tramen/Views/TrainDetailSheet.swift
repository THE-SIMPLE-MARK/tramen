import SwiftUI

struct TrainDetailSheet: View {
    let initialTrain: VehiclePositions
    @ObservedObject var trainDataService: TrainDataService

    var train: VehiclePositions? {
        trainDataService.trainData?.vehiclePositions.first { $0.vehicleId == initialTrain.vehicleId }
    }

    var currentTrain: VehiclePositions {
        train ?? initialTrain
    }

    var delaySeconds: Int64 {
        TimeFormatHelper.getCurrentDelay(
            stoptimes: currentTrain.trip.stoptimes,
            nowSeconds: TimeFormatHelper.getNowInSeconds()
        )
    }

    var delayMinutes: Int {
        Int(delaySeconds / 60)
    }

    var nextStopInfo: (name: String, delay: String)? {
        let nowSeconds = TimeFormatHelper.getNowInSeconds()
        for stop in currentTrain.trip.stoptimes {
            if stop.realtimeArrival > nowSeconds {
                return (name: stop.stop.name, delay: TimeFormatHelper.formatDelay(seconds: stop.arrivalDelay))
            }
        }
        return nil
    }

    var body: some View {
        List {
            Section("Overview") {
                OverviewContent(
                    train: currentTrain,
                    delayMinutes: delayMinutes,
                    nextStopInfo: nextStopInfo
                )
            }

            Section("Details") {
                DetailsContent(train: currentTrain)
            }

            Section("Stops (\(currentTrain.trip.stoptimes.count))") {
                StopsContent(train: currentTrain)
            }
        }
        .navigationTitle("Train Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OverviewContent: View {
    let train: VehiclePositions
    let delayMinutes: Int
    let nextStopInfo: (name: String, delay: String)?

    @Environment(\.sizeCategory) var sizeCategory

    var scheduleStatus: String {
        if delayMinutes == 0 {
            return String(localized: "On time")
        } else if delayMinutes > 0 {
            return String(localized: "\(delayMinutes) min behind")
        } else {
            return String(localized: "\(-delayMinutes) min ahead")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Route")
                    .font(.system(.caption))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Image(systemName: TrainTypeHelper.icon(for: train.trip.route.mode))
                        .font(.system(.title3))
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(train.trip.route.longName ?? train.trip.route.shortName ?? String(localized: "N/A"))
                            .font(.system(.caption2))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.secondary, in: RoundedRectangle(cornerRadius: 4))

                        Text(train.trip.tripHeadsign ?? String(localized: "N/A"))
                            .font(.system(.subheadline))
                            .fontWeight(.semibold)
                    }

                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(DelayColors.colorForDelay(minutes: delayMinutes))
                        .frame(width: 10, height: 10)

                    Text("Schedule")
                        .font(.system(.caption))
                        .foregroundColor(.secondary)
                }

                Text(scheduleStatus)
                    .font(.system(.body))
                    .fontWeight(.semibold)
                    .foregroundColor(DelayColors.colorForDelay(minutes: delayMinutes))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "speedometer")
                        .font(.system(.caption))
                        .foregroundColor(.secondary)

                    Text("Speed")
                        .font(.system(.caption))
                        .foregroundColor(.secondary)
                }

                Text("\(Int(train.speed ?? 0)) km/h")
                    .font(.system(.body))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let nextStop = nextStopInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next Stop")
                        .font(.system(.caption))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(.title3))
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(nextStop.name)
                                .font(.system(.subheadline))
                                .fontWeight(.semibold)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

struct DetailsContent: View {
    let train: VehiclePositions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(label: String(localized: "Callsign"), value: train.trip.tripShortName ?? "Unknown")

            Divider()

            InfoRow(label: String(localized: "UIC Number"), value: UICFormatter.format(vehicleId: train.vehicleId))

            Divider()

            InfoRow(label: String(localized: "Type"), value: TrainTypeHelper.displayName(for: train.trip.route.mode))

            Divider()

            InfoRow(
                label: String(localized: "Wheelchair Accessible"),
                value: train.trip.wheelchairAccessible == "POSSIBLE" ? String(localized: "Yes") : String(localized: "No")
            )

            Divider()

            InfoRow(
                label: String(localized: "Bikes Allowed"),
                value: train.trip.bikesAllowed == "ALLOWED" ? String(localized: "Yes") : String(localized: "No")
            )

            if let trainCategoryId = train.trip.trainCategoryId {
                Divider()
                InfoRow(label: String(localized: "Category"), value: trainCategoryId)
            }

            if let lastUpdated = train.lastUpdated {
                Divider()
                let date = Date(timeIntervalSince1970: TimeInterval(lastUpdated / 1000))
                InfoRow(label: String(localized: "Last Updated"), value: date.formatted(date: .omitted, time: .standard))
            }

            if let infoServices = train.trip.infoServices, !infoServices.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Services")
                        .font(.system(.caption))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(infoServices, id: \.name) { service in
                            if let name = service.name {
                                Text("• \(name)")
                                    .font(.system(.caption))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct StopsContent: View {
    let train: VehiclePositions

    var body: some View {
        let nowSeconds = TimeFormatHelper.getNowInSeconds()

        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(train.trip.stoptimes.enumerated()), id: \.element.stop.name) { index, stopTime in
                let isPassed = (stopTime.realtimeDeparture < nowSeconds)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .center, spacing: 0) {
                            if isPassed {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.green)
                            } else if index == 0 {
                                Image(systemName: "location.circle.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 24, height: 24)
                        .flexibleFrame(horizontal: false)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(stopTime.stop.name)
                                    .font(.system(.subheadline))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)

                                Spacer()

                                if let platformCode = stopTime.stop.platformCode, !platformCode.isEmpty {
                                    Text("Plt. \(platformCode)")
                                        .font(.system(.caption2))
                                        .foregroundColor(.secondary)
                                }
                            }

                            HStack(alignment: .top, spacing: 24) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Arrival")
                                        .font(.system(.caption2))
                                        .foregroundColor(.secondary)

                                    Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.scheduledArrival))
                                        .font(.system(.caption))
                                        .foregroundColor(.primary)

                                    if stopTime.realtimeArrival != stopTime.scheduledArrival {
                                        Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.realtimeArrival))
                                            .font(.system(.caption2))
                                            .fontWeight(.semibold)
                                            .foregroundColor(stopTime.arrivalDelay ?? 0 > 0 ? .red : .green)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Departure")
                                        .font(.system(.caption2))
                                        .foregroundColor(.secondary)

                                    Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.scheduledDeparture))
                                        .font(.system(.caption))
                                        .foregroundColor(.primary)

                                    if stopTime.realtimeDeparture != stopTime.scheduledDeparture {
                                        Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.realtimeDeparture))
                                            .font(.system(.caption2))
                                            .fontWeight(.semibold)
                                            .foregroundColor(stopTime.departureDelay ?? 0 > 0 ? .red : .green)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Spacer()
                            }
                        }
                    }
                }
                .opacity(isPassed ? 0.6 : 1.0)

                if index < train.trip.stoptimes.count - 1 {
                    Divider()
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.caption))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(.caption))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

extension View {
    func flexibleFrame(horizontal: Bool = true, vertical: Bool = true) -> some View {
        frame(maxWidth: horizontal ? .infinity : nil, maxHeight: vertical ? .infinity : nil)
    }
}

#Preview {
    let mockVehicle = VehiclePositions(
        stopRelationship: nil,
        vehicleId: "test:123456789",
        label: "IC 123",
        trip: Trip(
            route: Route(mode: "RAIL", shortName: "IC", longName: "InterCity", textColor: nil, color: "#FF0000"),
            tripGeometry: nil,
            wheelchairAccessible: "POSSIBLE",
            tripHeadsign: "Budapest - Debrecen",
            tripShortName: "IC 123",
            domesticResTrainNumber: nil,
            routeShortName: nil,
            bikesAllowed: "ALLOWED",
            pattern: nil,
            tripNumber: nil,
            gtfsId: nil,
            trainCategoryId: nil,
            id: nil,
            infoServices: nil,
            stoptimes: [],
            alerts: nil,
            arrivalStoptime: nil,
            trainCategoryBaseId: nil
        ),
        lat: 47.5,
        lon: 19.0,
        heading: 45,
        lastUpdated: nil,
        speed: 120,
        nextStop: nil
    )

		TrainDetailSheet(
        initialTrain: mockVehicle,
        trainDataService: TrainDataService()
    )
}
