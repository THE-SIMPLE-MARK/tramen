import CoreLocation
import Foundation

/// Decodes Google's polyline encoding format into an array of CLLocationCoordinate2D
enum PolylineDecoder {
    /// Decodes a Google-encoded polyline string into coordinates
    /// - Parameter encoded: The encoded polyline string
    /// - Returns: Array of CLLocationCoordinate2D representing the decoded path
    static func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        guard !encoded.isEmpty else { return [] }

        var coordinates: [CLLocationCoordinate2D] = []
        var index = 0
        var lat: Int32 = 0
        var lng: Int32 = 0

        let bytes = Array(encoded.utf8)

        while index < bytes.count {
            var shift = 0
            var result = 0
            var byte: Int32

            repeat {
                byte = Int32(bytes[index]) - 63
                index += 1
                result |= Int(byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1)
            lat += Int32(dlat)

            shift = 0
            result = 0

            repeat {
                byte = Int32(bytes[index]) - 63
                index += 1
                result |= Int(byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1)
            lng += Int32(dlng)

            let coordinate = CLLocationCoordinate2D(
                latitude: Double(lat) * 1e-5,
                longitude: Double(lng) * 1e-5
            )
            coordinates.append(coordinate)
        }

        return coordinates
    }
}
