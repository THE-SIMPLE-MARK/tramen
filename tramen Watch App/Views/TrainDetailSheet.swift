import SwiftUI

struct TrainDetailSheet: View {
    let train: VehiclePositions
    @ObservedObject var trainDataService: TrainDataService
    @Environment(\.dismiss) var dismiss

    var delaySeconds: Int64 {
        TimeFormatHelper.getCurrentDelay(
            stoptimes: train.trip.stoptimes,
            nowSeconds: TimeFormatHelper.getNowInSeconds()
        )
    }

    var delayMinutes: Int {
        Int(delaySeconds / 60)
    }

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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: TrainTypeHelper.icon(for: train.trip.route.mode))
                            .font(.system(.caption))
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)

                        Text(train.trip.route.longName ?? train.trip.route.shortName ?? String(localized: "N/A"))
                            .font(.system(.caption2))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.secondary, in: RoundedRectangle(cornerRadius: 4))

                        Spacer()
                    }

                    Text(train.trip.tripHeadsign ?? String(localized: "N/A"))
                        .font(.system(.caption))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Schedule")
                        .font(.system(.caption))
                        .foregroundColor(.secondary)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(DelayColors.colorForDelay(minutes: delayMinutes))
                            .frame(width: 8, height: 8)

                        Text(scheduleStatus)
                            .font(.system(.body))
                            .fontWeight(.semibold)
                            .foregroundColor(DelayColors.colorForDelay(minutes: delayMinutes))
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Speed")
                        .font(.system(.caption))
                        .foregroundColor(.secondary)

                    Text("\(Int(train.speed ?? 0)) km/h")
                        .font(.system(.body))
                        .fontWeight(.semibold)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    InfoRowSmall(label: String(localized: "Callsign"), value: train.trip.tripShortName ?? "Unknown")

                    InfoRowSmall(label: String(localized: "Type"), value: TrainTypeHelper.displayName(for: train.trip.route.mode))
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stops (\(train.trip.stoptimes.count))")
                        .font(.system(.caption))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    StopsContentWatch(train: train)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Train Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StopsContentWatch: View {
    let train: VehiclePositions

    var body: some View {
        let nowSeconds = TimeFormatHelper.getNowInSeconds()

        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(train.trip.stoptimes.enumerated()), id: \.element.stop.name) { index, stopTime in
                let isPassed = (stopTime.realtimeDeparture < nowSeconds)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .top, spacing: 8) {
                        if isPassed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        } else if index == 0 {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(stopTime.stop.name)
                                .font(.system(.caption2))
                                .fontWeight(.semibold)
                                .lineLimit(2)

                            if let platformCode = stopTime.stop.platformCode, !platformCode.isEmpty {
                                Text("Plt. \(platformCode)")
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.scheduledArrival))
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundColor(.primary)

                                    if stopTime.realtimeArrival != stopTime.scheduledArrival {
                                        Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.realtimeArrival))
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(stopTime.arrivalDelay ?? 0 > 0 ? .red : .green)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 0) {
                                    Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.scheduledDeparture))
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundColor(.primary)

                                    if stopTime.realtimeDeparture != stopTime.scheduledDeparture {
                                        Text(TimeFormatHelper.formatSecondsSinceMidnight(stopTime.realtimeDeparture))
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(stopTime.departureDelay ?? 0 > 0 ? .red : .green)
                                    }
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .opacity(isPassed ? 0.6 : 1.0)

                if index < train.trip.stoptimes.count - 1 {
                    Divider()
                        .padding(.vertical, 2)
                }
            }
        }
    }
}

struct InfoRowSmall: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.caption2))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(.caption2))
                .fontWeight(.semibold)
        }
    }
}
