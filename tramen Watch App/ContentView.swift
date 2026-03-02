import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var trainDataService = TrainDataService()
    @State private var selectedTrain: VehiclePositions?
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            Map(position: $mapPosition) {
                UserAnnotation()

                if let trains = trainDataService.trainData?.vehiclePositions {
                    ForEach(trains) { train in
                        let delaySeconds = TimeFormatHelper.getCurrentDelay(
                            stoptimes: train.trip.stoptimes,
                            nowSeconds: TimeFormatHelper.getNowInSeconds()
                        )
                        let delayMinutes = Int(delaySeconds / 60)
                        let isSelected = selectedTrain?.vehicleId == train.vehicleId

                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: train.lat, longitude: train.lon)) {
                            VStack(spacing: 0) {
                                Image(systemName: "triangle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DelayColors.colorForDelay(minutes: delayMinutes))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .scaleEffect(isSelected ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isSelected)
                            .onTapGesture {
                                selectTrain(train)
                            }
                        }
                    }
                }

                if !routeCoordinates.isEmpty {
                    MapPolyline(coordinates: routeCoordinates)
                        .stroke(.red, lineWidth: 2)
                }
            }
            .mapStyle(.standard)
            .onTapGesture { _ in
                selectedTrain = nil
                routeCoordinates = []
            }
            .onAppear {
                if let location = locationService.userLocation {
                    mapPosition = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    ))
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    trainDataService.startRefreshing()
                } else {
                    trainDataService.stopRefreshing()
                }
            }
        }
        .sheet(item: $selectedTrain) { train in
            TrainDetailSheet(train: train, trainDataService: trainDataService)
        }
    }

    private func selectTrain(_ train: VehiclePositions) {
        selectedTrain = train

        if let points = train.trip.tripGeometry?.points {
            routeCoordinates = PolylineDecoder.decode(points)
        }
    }
}



#Preview {
    ContentView()
}
