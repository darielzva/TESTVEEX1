//
//  ContentView.swift
//  CRACKED BY @DIDIERXIT7
//

import SwiftUI
import UIKit
import AVFoundation

// MARK: - Error
enum VexxError: LocalizedError, CustomStringConvertible {
    case message(String)
    var description: String {
        switch self { case .message(let m): return m }
    }
    var errorDescription: String? { description }
}

// MARK: - Audio
@MainActor
final class VexxAudio {
    static let shared = VexxAudio()
    private var player: AVAudioPlayer?
    func play(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

// MARK: - Catálogo
enum VexxTab: String, CaseIterable, Identifiable {
    case aimbots = "Aimbots"
    case holograms = "Hologramas"
    case guest = "Borrar Invitado"
    var id: String { rawValue }
}

struct VexxRow: Identifiable {
    let id: String
    let title: String
    let pkg: String
    let tab: VexxTab
}

enum VexxCatalog {
    static let password = "Levi-externas-veex-6393*#%"
    static let rows: [VexxRow] = [
        .init(id: "antena",  title: "Aim Drag Antena",       pkg: "aim_drag_antena", tab: .aimbots),
        .init(id: "drag",    title: "Aim Drag",              pkg: "aim_drag",        tab: .aimbots),
        .init(id: "pecho",   title: "Aim Pecho",             pkg: "aim_pecho",       tab: .aimbots),
        .init(id: "balas",   title: "Balas Mágicas",         pkg: "balas_magicas",   tab: .aimbots),
        .init(id: "holoarm", title: "Hologramas Armas",      pkg: "holo_arma",       tab: .holograms),
        .init(id: "holoper", title: "Hologramas Personajes", pkg: "holo_personaje",  tab: .holograms),
        .init(id: "guest",   title: "Reset Guest",           pkg: "Reset Guest",     tab: .guest)
    ]

    static func norm(_ s: String) -> String {
        s.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    static var aimbots: [VexxRow] { rows.filter { $0.tab == .aimbots } }

    static var reserved: Set<String> {
        var s = Set<String>()
        for r in rows {
            s.insert(norm(r.pkg))
            s.insert(norm(r.title))
        }
        return s
    }
}

// MARK: - Tema
enum VexxTheme {
    static var metal: LinearGradient {
        LinearGradient(
            colors: [.white, Color(white: 0.62), Color(white: 0.95), Color(white: 0.70)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    static var card: Color { Color.white.opacity(0.055) }
    static var stroke: Color { Color.white.opacity(0.13) }
    static var dim: Color { Color.white.opacity(0.42) }
}

enum VexxSupport {
    static var isSupported: Bool {
        let major = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        return major >= 16 && major <= 27
    }

    static let ranges = "iOS 17.0–17.7 · 18.0–18.7.1 · 26.0–26.6.1 · 27 betas 1–4"
}

// MARK: - Raíz
struct ContentView: View {
    var body: some View {
        VexxMain()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Principal
struct VexxMain: View {
    @EnvironmentObject private var store: PatchProjectStore

    @State private var tab: VexxTab = .aimbots
    @State private var on: Set<String> = []
    @State private var busy: String?
    @State private var error: String?
    @State private var showSettings = false

    private var rows: [VexxRow] {
        VexxCatalog.rows.filter { $0.tab == tab }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                RadialGradient(
                    colors: [.white.opacity(0.07), .clear],
                    center: .top,
                    startRadius: 20,
                    endRadius: 340
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    if let error {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 11))
                            Text(error)
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(8)
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.12))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Picker("", selection: $tab) {
                        ForEach(VexxTab.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    ScrollView {
                        VStack(spacing: 9) {
                            ForEach(rows) { row in
                                rowView(row)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    Button { openFF() } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "gamecontroller.fill").font(.system(size: 13))
                            Text("Abrir Free Fire").font(.system(size: 15, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                        .foregroundStyle(.black)
                        .shadow(color: .white.opacity(0.22), radius: 18, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .task { sync() }
            .sheet(isPresented: $showSettings) { VexxSettings() }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("cracked by @didierxit7")
                    .font(.system(size: 17, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(VexxTheme.metal)
                    .shadow(color: .white.opacity(0.22), radius: 10)
                HStack(spacing: 5) {
                    Circle()
                        .fill(VexxSupport.isSupported ? .green : .red)
                        .frame(width: 6, height: 6)
                    Text(VexxSupport.isSupported ? "soportado" : "no soportado")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(VexxSupport.isSupported ? .green : .red)
                }
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(9)
                    .background(VexxTheme.card, in: Circle())
                    .overlay(Circle().stroke(VexxTheme.stroke))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }

    private func rowView(_ row: VexxRow) -> some View {
        let active = on.contains(row.id)
        let working = busy == row.id
        return HStack(spacing: 12) {
            Text(row.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            if working {
                ProgressView().tint(.white).scaleEffect(0.8)
            } else {
                Toggle("", isOn: Binding(get: { active }, set: { _ in toggle(row) }))
                    .labelsHidden()
                    .tint(active ? .green : .red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(VexxTheme.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(VexxTheme.stroke))
    }

    // MARK: Lógica
    private func cacheKey(_ r: VexxRow) -> String { "veex.id." + r.id }

    private func cache(_ id: UUID, _ r: VexxRow) {
        UserDefaults.standard.set(id.uuidString, forKey: cacheKey(r))
    }

    private func exact(_ name: String, _ r: VexxRow) -> Bool {
        let n = VexxCatalog.norm(name)
        return !n.isEmpty && (n == VexxCatalog.norm(r.pkg) || n == VexxCatalog.norm(r.title))
    }

    private func loose(_ name: String, _ r: VexxRow) -> Bool {
        let n = VexxCatalog.norm(name)
        guard !n.isEmpty else { return false }
        let keys = [VexxCatalog.norm(r.pkg), VexxCatalog.norm(r.title)]
        for k in keys where !k.isEmpty {
            if n.hasPrefix(k) || k.hasPrefix(n) { return true }
            if n.contains(k) || k.contains(n) { return true }
        }
        return false
    }

    private func availablePackages() -> [URL] {
        let fm = FileManager.default
        let root = Bundle.main.bundleURL
        var raw: [URL] = []
        for dir in [root, root.appendingPathComponent("Frameworks")] {
            if let list = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
                raw += list.filter { $0.pathExtension.lowercased() == "3105" }
            }
        }
        if let extra = Bundle.main.urls(forResourcesWithExtension: "3105", subdirectory: nil) {
            raw += extra
        }
        var seen = Set<String>()
        var out: [URL] = []
        for url in raw where seen.insert(url.lastPathComponent.lowercased()).inserted {
            out.append(url)
        }
        return out
    }

    private func packageURL(_ r: VexxRow) -> URL? {
        let all = availablePackages()
        let names = { (u: URL) in u.deletingPathExtension().lastPathComponent }

        if let hit = all.first(where: { exact(names($0), r) }) { return hit }

        let reserved = VexxCatalog.reserved
        let others = all.filter { !reserved.contains(VexxCatalog.norm(names($0))) }
        return others.first(where: { loose(names($0), r) })
    }

    private func findItem(_ r: VexxRow) -> PatchLibraryItem? {
        if let raw = UserDefaults.standard.string(forKey: cacheKey(r)),
           let id = UUID(uuidString: raw),
           let hit = store.items.first(where: { $0.id == id }) {
            return hit
        }
        if let hit = store.items.first(where: { exact($0.project?.name ?? "", r) }) {
            cache(hit.id, r)
            return hit
        }
        let reserved = VexxCatalog.reserved
        if let hit = store.items.first(where: {
            let n = VexxCatalog.norm($0.project?.name ?? "")
            return !n.isEmpty && !reserved.contains(n) && loose(n, r)
        }) {
            cache(hit.id, r)
            return hit
        }
        return nil
    }

    private func sync() {
        var s = Set<String>()
        for row in VexxCatalog.rows {
            if let item = findItem(row), DevicePatchService.latestReceipt(projectID: item.id) != nil {
                s.insert(row.id)
            }
        }
        on = s
    }

    private func waitIdle() async {
        for _ in 0..<80 {
            if !store.isBusy { break }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        try? await Task.sleep(nanoseconds: 300_000_000)
    }

    private func toggle(_ row: VexxRow) {
        guard busy == nil else { return }
        busy = row.id
        error = nil
        let turningOn = !on.contains(row.id)
        Task {
            do {
                if turningOn {
                    try await turnOn(row)
                } else {
                    try await turnOff(row)
                }
                VexxAudio.shared.play(turningOn ? "on" : "off")
            } catch {
                self.error = "\(row.title): \(String(describing: error))"
            }
            sync()
            busy = nil
        }
    }

    private func turnOn(_ row: VexxRow) async throws {
        if row.tab == .aimbots {
            for other in VexxCatalog.aimbots where other.id != row.id {
                try? await turnOff(other)
            }
            sync()
        }
        do {
            let item = try await importPackage(row)
            try await applyItem(item)
        } catch {
            let msg = String(describing: error).lowercased()
            guard row.tab == .aimbots, msg.contains("occupied") || msg.contains("bloqueado") else {
                throw error
            }
            var freed: [VexxRow] = []
            for other in VexxCatalog.rows where other.id != row.id && on.contains(other.id) {
                try? await turnOff(other)
                freed.append(other)
            }
            sync()
            let item = try await importPackage(row)
            try await applyItem(item)
            for other in freed { try? await turnOn(other) }
        }
    }

    private func turnOff(_ row: VexxRow) async throws {
        guard let item = findItem(row) else {
            on.remove(row.id)
            return
        }
        if let receipt = DevicePatchService.latestReceipt(projectID: item.id) {
            await waitIdle()
            try await Task.detached(priority: .userInitiated) {
                _ = try DevicePatchService.inspectRestore(receipt: receipt)
                try DevicePatchService.restore(receipt: receipt, allowChangedTargets: true)
            }.value
            store.reload()
        }
        if row.tab == .aimbots {
            await waitIdle()
            try? PatchProjectLibrary.delete(item)
            store.reload()
            UserDefaults.standard.removeObject(forKey: cacheKey(row))
        }
    }

    private func importPackage(_ row: VexxRow) async throws -> PatchLibraryItem {
        if let existing = findItem(row) { return existing }
        guard let url = packageURL(row) else {
            let names = availablePackages().map { $0.lastPathComponent }.sorted()
            throw VexxError.message(
                "falta \(row.pkg).3105 · ipa: \(names.isEmpty ? "vacío" : names.joined(separator: " | "))"
            )
        }
        let data = try Data(contentsOf: url)

        for attempt in 1...4 {
            await waitIdle()
            let before = Set(store.items.map(\.id))
            guard store.importPackage(data: data, password: VexxCatalog.password) else {
                try? await Task.sleep(nanoseconds: 400_000_000)
                continue
            }
            await waitIdle()
            if let fresh = store.items.first(where: { !before.contains($0.id) }) {
                cache(fresh.id, row)
                return fresh
            }
            if let existing = findItem(row) { return existing }
            try? await Task.sleep(nanoseconds: UInt64(attempt) * 400_000_000)
        }
        throw VexxError.message("import falló")
    }

    private func applyItem(_ item: PatchLibraryItem) async throws {
        let project: PatchProject
        if item.summary.schemaVersion >= 2, item.canInspectContents {
            project = try PatchProjectLibrary.synchronizeWorkspace(item: item)
        } else if let base = item.project {
            project = base
        } else {
            throw VexxError.message("parche bloqueado")
        }
        await waitIdle()
        try await Task.detached(priority: .userInitiated) {
            _ = try DevicePatchService.apply(project: project)
        }.value
        store.reload()
    }

    private func openFF() {
        let schemes = ["freefire://", "freefiremax://"]
        func attempt(_ i: Int) {
            guard i < schemes.count, let url = URL(string: schemes[i]) else { return }
            UIApplication.shared.open(url, options: [:]) { ok in
                if !ok { attempt(i + 1) }
            }
        }
        attempt(0)
    }
}

// MARK: - Ajustes
struct VexxSettings: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                List {
                    Section {
                        LabeledContent("Estado") {
                            Text("Bypassed")
                                .foregroundStyle(.green)
                        }
                        LabeledContent("iOS") {
                            Text(ProcessInfo.processInfo.operatingSystemVersionString)
                        }
                    } header: {
                        Text("Información")
                    }

                    Section {
                        Text(VexxSupport.ranges)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    } header: {
                        Text("Soportado")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}
