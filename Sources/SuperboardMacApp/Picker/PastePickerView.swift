import SwiftUI
import SuperboardCore

struct PastePickerView: View {
    private static let rowHeight: CGFloat = 32
    private static let maxVisibleRows: CGFloat = 5

    @ObservedObject var session: PastePickerSession
    let onChoose: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(session.visibleItems.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 8) {
                            Text(item.previewText)
                                .font(.system(size: 11, weight: index == session.selectedIndex ? .semibold : .regular))
                                .lineLimit(1)
                            Spacer(minLength: 6)
                            Text(item.sourceAppName)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: Self.rowHeight, alignment: .leading)
                        .padding(.horizontal, 8)
                        .background(index == session.selectedIndex ? Color.accentColor.opacity(0.16) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .id(item.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            session.select(index: index)
                            onChoose()
                        }
                    }
                }
                .padding(8)
            }
            .onAppear {
                scrollSelection(into: proxy)
            }
            .onChange(of: session.selectedIndex) { _, _ in
                scrollSelection(into: proxy)
            }
        }
        .scrollIndicators(.never)
        .frame(width: PastePickerPanelController.panelSize.width)
        .frame(height: (Self.rowHeight * Self.maxVisibleRows) + 16, alignment: .top)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.96), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
        .onExitCommand {
            onCancel()
        }
    }

    private func scrollSelection(into proxy: ScrollViewProxy) {
        guard session.visibleItems.indices.contains(session.selectedIndex) else { return }
        let item = session.visibleItems[session.selectedIndex]
        proxy.scrollTo(item.id, anchor: .center)
    }
}
