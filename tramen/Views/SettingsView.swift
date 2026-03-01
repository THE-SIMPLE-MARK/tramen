import SwiftUI
import Combine

struct SettingsView: View {
    @Binding var refreshInterval: TimeInterval
    @Environment(\.dismiss) var dismiss
    @State private var sliderValue: Double = 0
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Refresh Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Update Frequency")
                            Spacer()
                            Text("\(Int(sliderValue))s")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $sliderValue,
                            in: 5...60,
                            step: 5
                        )
                        .onChange(of: sliderValue) { _, newValue in
                            // Cancel previous debounce task
                            cancellable?.cancel()
                            
                            // Debounce: only update after 0.5s of inactivity
                            cancellable = Just(newValue)
                                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                                .sink { debouncedValue in
                                    refreshInterval = debouncedValue
                                }
                        }
                        
                        Text("Updates every \(Int(sliderValue)) seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                sliderValue = refreshInterval
            }
        }
    }
}

#Preview {
	@Previewable @State var interval = 15.0
    return SettingsView(refreshInterval: $interval)
}
