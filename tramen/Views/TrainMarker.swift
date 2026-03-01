import SwiftUI
import MapKit

struct TrainMarkerAnnotation: View {
    let vehicle: VehiclePositions
    let delayMinutes: Int
    let isSelected: Bool
    
    var markerColor: Color {
        DelayColors.colorForDelay(minutes: delayMinutes)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Triangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 26, height: 32)
                    .offset(y: 2)
                
                Triangle()
                    .fill(markerColor)
                    .frame(width: 24, height: 30)
                    .overlay(
                        Triangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 24, height: 30)
                    )
            }
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
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
            wheelchairAccessible: nil,
            tripHeadsign: nil,
            tripShortName: "IC 123",
            domesticResTrainNumber: nil,
            routeShortName: nil,
            bikesAllowed: nil,
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
    
    TrainMarkerAnnotation(vehicle: mockVehicle, delayMinutes: 5, isSelected: true)
        .frame(width: 50, height: 50)
}
