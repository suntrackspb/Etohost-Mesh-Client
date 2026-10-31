import SwiftUI
import WidgetKit
import AppIntents

private let blue = Color(red: 34/255, green: 125/255, blue: 243/255)
private let purple = Color(red: 136/255, green: 72/255, blue: 219/255)
private let pink = Color(red: 207/255, green: 62/255, blue: 131/255)
private let group = "group.ru.meshex.app"

struct MeshNode: Decodable, Identifiable {
    let num: Int64
    let name: String
    let battery: Int?
    let snr: Double?
    let heard: Double?
    var id: Int64 { num }
}
struct MeshMessage: Decodable, Identifiable {
    let sender: String
    let body: String
    let path: String
    var id: String { path + sender + body }
}
struct MeshTrace: Decodable {
    let path: String
    let time: Double
    let summary: String
    let back: String
}
struct MeshSnapshot: Decodable {
    let updated: Double
    let language: String
    let connected: Bool
    let name: String
    let online: Int
    let total: Int
    let battery: Int?
    let channel: String?
    let airtime: String?
    let tx: Int?
    let rx: Int?
    let dupe: Int?
    let relay: Int?
    let noise: Int?
    let uptime: Int?
    let unread: Int
    let mapped: Int
    let nodes: [MeshNode]
    let messages: [MeshMessage]
    let trace: MeshTrace?
    var date: Date { Date(timeIntervalSince1970: updated / 1000) }
    func tr(_ en: String, _ ru: String) -> String { language == "ru" ? ru : en }
    static func load() -> MeshSnapshot? {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group),
              let data = try? Data(contentsOf: url.appendingPathComponent("snapshot.json")) else { return nil }
        return try? JSONDecoder().decode(MeshSnapshot.self, from: data)
    }
}
struct MeshEntry: TimelineEntry {
    let date: Date
    let snapshot: MeshSnapshot?
    var selected: Int64? = nil
}
struct MeshProvider: TimelineProvider {
    func placeholder(in context: Context) -> MeshEntry { MeshEntry(date: .now, snapshot: nil) }
    func getSnapshot(in context: Context, completion: @escaping (MeshEntry) -> Void) { completion(MeshEntry(date: .now, snapshot: MeshSnapshot.load())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<MeshEntry>) -> Void) {
        let snapshot = MeshSnapshot.load()
        let now = Date()
        let stale = max(now.addingTimeInterval(60), (snapshot?.date ?? now).addingTimeInterval(7201))
        completion(Timeline(entries: [MeshEntry(date: now, snapshot: snapshot), MeshEntry(date: stale, snapshot: snapshot)], policy: .after(stale.addingTimeInterval(1800))))
    }
}
struct TrackedNode: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Node"
    static var defaultQuery = NodeQuery()
    var id: String
    var name: String
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
}
struct NodeQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TrackedNode] {
        let nodes = MeshSnapshot.load()?.nodes ?? []
        return identifiers.map { id in TrackedNode(id: id, name: nodes.first { String($0.num) == id }?.name ?? id) }
    }
    func suggestedEntities() async throws -> [TrackedNode] { (MeshSnapshot.load()?.nodes ?? []).map { TrackedNode(id: String($0.num), name: $0.name) } }
}
struct TrackIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Track node"
    @Parameter(title: "Node") var node: TrackedNode?
}
struct TrackerProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MeshEntry { MeshEntry(date: .now, snapshot: nil) }
    func snapshot(for configuration: TrackIntent, in context: Context) async -> MeshEntry { MeshEntry(date: .now, snapshot: MeshSnapshot.load(), selected: configuration.node.flatMap { Int64($0.id) }) }
    func timeline(for configuration: TrackIntent, in context: Context) async -> Timeline<MeshEntry> {
        let snapshot = MeshSnapshot.load()
        let now = Date()
        let stale = max(now.addingTimeInterval(60), (snapshot?.date ?? now).addingTimeInterval(7201))
        return Timeline(entries: [MeshEntry(date: now, snapshot: snapshot, selected: configuration.node.flatMap { Int64($0.id) }), MeshEntry(date: stale, snapshot: snapshot, selected: configuration.node.flatMap { Int64($0.id) })], policy: .after(stale.addingTimeInterval(1800)))
    }
}

struct MeshWidgetView: View {
    @Environment(\.widgetFamily) var family
    let kind: String
    let entry: MeshEntry
    private var large: Bool { family == .systemLarge }
    private var small: Bool { family == .systemSmall }
    private var path: String {
        switch kind {
        case "tracker": return entry.selected.map { "/nodes/\($0)" } ?? "/nodes"
        case "messages": return "/chat"
        case "map": return "/map"
        case "route": return entry.snapshot?.trace?.path ?? "/nodes"
        default: return "/connection"
        }
    }
    private var title: String {
        let titles = ["status": "Mesh Status", "tracker": "Node Tracker", "messages": "Messages", "map": "Node Map", "route": "Trace Route"]
        return titles[kind] ?? "Meshex"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("meshex").font(.headline).foregroundStyle(LinearGradient(colors: [blue, purple, pink], startPoint: .leading, endPoint: .trailing))
                Spacer(minLength: 0)
                if !small { Text(title).font(.caption).foregroundStyle(.secondary).lineLimit(1) }
            }
            if small { Text(title).font(.caption2).foregroundStyle(.secondary) }
            if let s = entry.snapshot {
                content(s)
                Spacer(minLength: 0)
                HStack(spacing: 4) {
                    if entry.date.timeIntervalSince(s.date) > 7200 { Image(systemName: "clock.badge.exclamationmark").foregroundStyle(pink) }
                    Text(s.tr("Updated", "Обновлено"))
                    Text(s.date, style: .time)
                }.font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            } else {
                Spacer(minLength: 0)
                Image(systemName: symbol).font(.title).foregroundStyle(blue)
                Text("Open Meshex to load your mesh / Откройте Meshex").font(.caption)
                Spacer(minLength: 0)
            }
        }
        .widgetURL(URL(string: "meshex://\(path)"))
        .containerBackground(.background, for: .widget)
    }
    private var symbol: String { ["status":"antenna.radiowaves.left.and.right", "tracker":"scope", "messages":"bubble.left.and.bubble.right", "map":"map", "route":"point.topleft.down.to.point.bottomright.curvepath"][kind] ?? "antenna.radiowaves.left.and.right" }
    @ViewBuilder private func content(_ s: MeshSnapshot) -> some View {
        switch kind {
        case "tracker":
            if let node = s.nodes.first(where: { $0.num == entry.selected }) {
                Text(node.name).font(.headline).lineLimit(2)
                Label(battery(node.battery), systemImage: "battery.75percent").foregroundStyle(blue)
                if !small { Text("SNR \(node.snr.map { String(format: "%.1f dB", $0) } ?? "—")").font(.subheadline) }
                if let heard = node.heard {
                    Text(s.tr("Last heard", "В эфире")).font(.caption).foregroundStyle(.secondary)
                    Text(Date(timeIntervalSince1970: heard/1000), style: .relative).font(.caption)
                }
            } else { Text(s.tr("Edit widget to select a node. If already selected, it is unavailable in this mesh.", "Выберите ноду в настройках виджета. Если она уже выбрана — её нет в текущей сети.")).font(.caption) }
        case "messages":
            Text("\(s.unread) " + s.tr("unread", "непрочитанных")).font(.headline).foregroundStyle(purple)
            if s.messages.isEmpty { Text(s.tr("No messages yet", "Сообщений пока нет")).font(.caption) }
            ForEach(Array(s.messages.prefix(large ? 5 : 2).enumerated()), id: \.offset) { _, message in
                Link(destination: URL(string: "meshex://\(message.path)")!) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.sender).font(.caption).foregroundStyle(blue)
                        Text(message.body).font(.subheadline).foregroundStyle(.primary).lineLimit(2)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        case "map", "route":
            if kind == "route" { Text(s.trace?.summary ?? s.tr("No routes yet", "Трассировок пока нет")).font(.caption).lineLimit(large ? 3 : 2) }
            else { Text("\(s.mapped) " + s.tr("nodes on map", "нод на карте")).font(.subheadline) }
            if (kind == "map" && s.mapped > 0) || (kind == "route" && s.trace != nil) {
                if let image = mapImage(kind) {
                    GeometryReader { geometry in
                        Image(uiImage: image).resizable().scaledToFit().frame(width: geometry.size.width, height: geometry.size.height)
                    }.accessibilityLabel(title)
                } else { Text(s.tr("Open Meshex to load map tiles", "Откройте Meshex для загрузки карты")).font(.caption) }
            }
            if kind == "route", let trace = s.trace {
                if large && !trace.back.isEmpty { Text("↩ " + trace.back).font(.caption).lineLimit(2) }
                Text(Date(timeIntervalSince1970: trace.time/1000), style: .relative).font(.caption2).foregroundStyle(.secondary)
            }
        default:
            let connected = s.connected && entry.date.timeIntervalSince(s.date) <= 7200
            Label(connected ? s.tr("Connected", "Подключено") : s.tr("Disconnected", "Нет подключения"), systemImage: connected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash").font(.caption).foregroundStyle(connected ? blue : pink)
            Text(s.name).font(.headline).lineLimit(1)
            if connected {
                Text("\(s.online) / \(s.total) " + s.tr("nodes online", "нод онлайн")).font(.subheadline)
                Label(battery(s.battery), systemImage: "battery.75percent").font(.subheadline).foregroundStyle(purple)
                if !small {
                    HStack {
                        metric(s.tr("Channel", "Канал"), s.channel)
                        Spacer()
                        metric(s.tr("Airtime", "Эфир"), s.airtime)
                    }
                }
                if large {
                    Divider()
                    HStack { stat("TX", s.tx); Spacer(); stat("RX", s.rx) }
                    HStack { stat(s.tr("Duplicates", "Дубликаты"), s.dupe); Spacer(); stat(s.tr("Relayed", "Ретрансляции"), s.relay) }
                    if let noise = s.noise { Text(s.tr("Noise", "Шум") + " \(noise) dBm").font(.caption) }
                    if let uptime = s.uptime { Text(s.tr("Uptime", "Время работы") + " \(uptime / 3600)h \((uptime % 3600) / 60)m").font(.caption) }
                }
            } else { Text(s.tr("Open Meshex to connect", "Откройте Meshex для подключения")).font(.caption).foregroundStyle(.secondary) }
        }
    }
    private func stat(_ title: String, _ value: Int?) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value.map(String.init) ?? "—").font(.headline).monospacedDigit().foregroundStyle(purple)
        }
    }
    private func metric(_ title: String, _ value: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value.map { $0 + "%" } ?? "—").font(.title3).monospacedDigit().foregroundStyle(blue)
        }
    }
    private func battery(_ level: Int?) -> String {
        guard let level else { return "—" }
        return level > 100 ? "⚡︎" : "\(level)%"
    }
    private func mapImage(_ kind: String) -> UIImage? {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else { return nil }
        return UIImage(contentsOfFile: directory.appendingPathComponent("\(kind).png").path)
    }
}
struct StatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MeshexStatus", provider: MeshProvider()) { MeshWidgetView(kind: "status", entry: $0) }
            .configurationDisplayName("Mesh Status").description("Connection, nodes online and radio statistics.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
struct TrackerWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MeshexTracker", intent: TrackIntent.self, provider: TrackerProvider()) { MeshWidgetView(kind: "tracker", entry: $0) }
            .configurationDisplayName("Node Tracker").description("Battery, signal and last heard for a node you choose.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
struct MessagesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MeshexMessages", provider: MeshProvider()) { MeshWidgetView(kind: "messages", entry: $0) }
            .configurationDisplayName("Messages").description("Unread counts and recent mesh messages.")
            .supportedFamilies([.systemMedium, .systemLarge])
    }
}
struct MapWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MeshexMap", provider: MeshProvider()) { MeshWidgetView(kind: "map", entry: $0) }
            .configurationDisplayName("Node Map").description("Your mesh nodes on a map.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
struct RouteWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MeshexRoute", provider: MeshProvider()) { MeshWidgetView(kind: "route", entry: $0) }
            .configurationDisplayName("Trace Route").description("Your most recent completed trace route.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
@main struct MeshexWidgets: WidgetBundle {
    var body: some Widget {
        StatusWidget()
        TrackerWidget()
        MessagesWidget()
        MapWidget()
        RouteWidget()
    }
}
