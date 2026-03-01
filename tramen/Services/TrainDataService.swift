import Foundation
import Combine

class TrainDataService: ObservableObject {
    @Published var trainData: Holavonat?
    @Published var isLoading = false
    @Published var error: String?
    
    private var refreshTimer: Timer?
    private let refreshInterval: TimeInterval = 15.0
    private let apiUrl = "https://cdn.holavonat.is/train_data_v3.json"
    private let cacheFileName = "train_cache.json"
    
    private var cacheUrl: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(cacheFileName)
    }
    
    deinit {
        stopRefreshing()
    }
    
    func startRefreshing() {
        loadFromCache()
        
        fetchTrainData()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.fetchTrainData()
        }
    }
    
    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func fetchTrainData() {
        guard !isLoading else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.timeoutInterval = 10
        
        session.dataTask(with: request) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
            
            if let error = error {
                print("Fetch error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.error = "Failed to fetch: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.error = "No data received"
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Holavonat.self, from: data)
                
                DispatchQueue.main.async {
                    self?.trainData = response
                    self?.error = nil
                    self?.saveToCache(data)
                }
            } catch {
                print("Decode error: \(error)")
                DispatchQueue.main.async {
                    self?.error = "Failed to decode data"
                }
            }
        }.resume()
    }
    
    private func loadFromCache() {
        guard let cacheUrl = cacheUrl else { return }
        
        do {
            let data = try Data(contentsOf: cacheUrl)
            let decoder = JSONDecoder()
            let response = try decoder.decode(Holavonat.self, from: data)
            
            DispatchQueue.main.async {
                self.trainData = response
            }
        } catch {
            print("Cache load error: \(error)")
        }
    }
    
    private func saveToCache(_ data: Data) {
        guard let cacheUrl = cacheUrl else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: cacheUrl)
            } catch {
                print("Cache save error: \(error)")
            }
        }
    }
}
