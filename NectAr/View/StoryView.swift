import SwiftUI

struct StoryView: View {
    @State private var selection: Story.ID?
    let onSelect: (Story) -> Void

    var body: some View {
        NavigationSplitView {
            List(StoryCatalog.all, selection: $selection) { story in
                Label(story.title, systemImage: story.icon)
            }
            .listStyle(.sidebar)
            .navigationTitle("Stories")
        } detail: {
            Text("Select a story to begin")
                .foregroundStyle(.secondary)
        }
        .onChange(of: selection) { _, newValue in
            if let story = StoryCatalog.all.first(where: { $0.id == newValue }) {
                onSelect(story)
            }
        }
    }
}

#Preview {
    StoryView(onSelect: { _ in })
}
