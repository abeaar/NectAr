import SwiftUI

struct StoryView: View {
    @Binding var selection: Story.ID?

    var body: some View {
        List(StoryCatalog.all, selection: $selection) { story in
            Label(story.title, systemImage: story.icon)
        }
        .listStyle(.sidebar)
        .navigationTitle("Stories")
    }
}
