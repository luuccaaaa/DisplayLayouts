import Foundation

struct LayoutProfile: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var args: [String] // displayplacer per-display argument strings
    var createdAt: Date
    var updatedAt: Date
}

extension Notification.Name {
    static let profilesStoreDidChange = Notification.Name("ProfilesStoreDidChange")
}

final class ProfilesStore: ObservableObject {
    @Published private(set) var profiles: [LayoutProfile] = []

    private let fileURL: URL = {
        let fm = FileManager.default
        let appSupport = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = appSupport.appendingPathComponent("DisplayLayouts", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("profiles.json")
    }()

    init() {
        _ = load()
    }

    @discardableResult
    func load() -> [LayoutProfile] {
        do {
            let data = try Data(contentsOf: fileURL)
            profiles = try JSONDecoder().decode([LayoutProfile].self, from: data)
        } catch {
            profiles = []
        }
        return profiles
    }

    func save() throws {
        let data = try JSONEncoder().encode(profiles)
        try data.write(to: fileURL, options: [.atomic])
        NotificationCenter.default.post(name: .profilesStoreDidChange, object: nil)
    }

    func add(name: String, args: [String]) throws -> LayoutProfile {
        let now = Date()
        let profile = LayoutProfile(id: UUID(), name: name, args: args, createdAt: now, updatedAt: now)
        profiles.append(profile)
        try save()
        return profile
    }

    func update(_ profile: LayoutProfile) throws {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
            try save()
        }
    }

    func remove(id: UUID) throws {
        profiles.removeAll { $0.id == id }
        try save()
    }

    func rename(id: UUID, to newName: String) throws {
        guard let idx = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[idx].name = newName
        profiles[idx].updatedAt = Date()
        try save()
    }

    func move(fromOffsets: IndexSet, toOffset: Int) throws {
        profiles.move(fromOffsets: fromOffsets, toOffset: toOffset)
        try save()
    }
}
