import SwiftUI

struct RefreshingIndicator: View {
    let isShowing: Bool

    var body: some View {
        if isShowing {
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Refreshing...")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    VStack {
        RefreshingIndicator(isShowing: true)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
