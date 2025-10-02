import SwiftUI

struct ManageProfilesView: View {
    @ObservedObject var store: ProfilesStore
    let onClose: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Manage Layouts").font(.headline)
                Spacer()
            }

            List {
                ForEach(store.profiles) { profile in
                    HStack {
                        TextField("Name", text: bindingForName(profile))
                            .textFieldStyle(.roundedBorder)
                        Spacer()
                        Button(role: .destructive) {
                            try? store.remove(id: profile.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                        .help("Delete layout")
                    }
                    .padding(.vertical, 2)
                }
                .onMove { indices, newOffset in
                    try? store.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .listStyle(.inset)
            .frame(minHeight: 240)

            HStack {
                Spacer()
                Button("Close") { onClose?() }
                    .keyboardShortcut(.cancelAction)
            }
        }
        .padding(16)
        .frame(width: 420, height: 340)
    }

    private func bindingForName(_ profile: LayoutProfile) -> Binding<String> {
        Binding<String>(
            get: {
                store.profiles.first(where: { $0.id == profile.id })?.name ?? profile.name
            },
            set: { newValue in
                try? store.rename(id: profile.id, to: newValue)
            }
        )
    }
}
