import SwiftUI
import SuperboardCore

struct PastePickerView: View {
    @ObservedObject var session: PastePickerSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(session.visibleItems.enumerated()), id: \.element.id) { index, item in
                HStack {
                    Text(item.previewText)
                        .font(.system(size: 13, weight: index == session.selectedIndex ? .semibold : .regular))
                    Spacer()
                    Text(item.sourceAppName)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(index == session.selectedIndex ? Color.accentColor.opacity(0.16) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .frame(width: 360)
    }
}
