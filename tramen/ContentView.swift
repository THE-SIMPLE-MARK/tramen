import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var trainDataService = TrainDataService()
    @State private var selectedTrain: VehiclePositions?
    @State private var showTrainInfo = false
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    
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
                                    .font(.system(.title3, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(DelayColors.colorForDelay(minutes: delayMinutes))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .scaleEffect(isSelected ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isSelected)
                            .onTapGesture {
                                selectTrain(train)
                            }
                        }
                    }
                }
                
                if !routeCoordinates.isEmpty {
                    MapPolyline(coordinates: routeCoordinates)
                        .stroke(.red, lineWidth: 3)
                }
            }
            .mapStyle(.standard)
            .onTapGesture { location in
                selectedTrain = nil
                showTrainInfo = false
                routeCoordinates = []
            }
            .onAppear {
                trainDataService.startRefreshing()
                if let location = locationService.userLocation {
                    mapPosition = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
            }
            .onDisappear {
                trainDataService.stopRefreshing()
            }
            
            VStack {
                RefreshingIndicator(isShowing: trainDataService.isLoading)
                Spacer()
            }

        }
        .sheet(isPresented: $showTrainInfo) {
            if let train = selectedTrain {
                NavigationStack {
                    TrainInfoSheet(initialTrain: train, trainDataService: trainDataService)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func selectTrain(_ train: VehiclePositions) {
        selectedTrain = train
        showTrainInfo = true
        
        if let points = train.trip.tripGeometry?.points {
            routeCoordinates = PolylineDecoder.decode(points)
        }
    }
    
    private func dismissSheet() {
        showTrainInfo = false
        selectedTrain = nil
        routeCoordinates = []
    }
}

#Preview {
    ContentView()
}
