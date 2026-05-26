import AudioToolbox
import AVFoundation
import Foundation
import OSLog
import TangoDisplayCore

/// Manages factory and user presets for a loaded AVAudioUnit.
///
/// User presets are stored in:
///   ~/Library/Application Support/TangoDisplay/AUPresets/{componentSubType}/
///
/// Each user preset is a JSON file ({uuid}.aupreset) containing the preset name and
/// the AU's ClassInfo property list encoded as base64.
final class AudioUnitPresetManager {

    private let storeURL: URL

    init(for selection: AudioUnitPluginSelection) {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        storeURL = appSupport
            .appendingPathComponent("TangoDisplay/AUPresets/\(selection.componentSubType)",
                                    isDirectory: true)
        try? FileManager.default.createDirectory(at: storeURL, withIntermediateDirectories: true)
    }

    // MARK: - Factory presets

    func factoryPresets(for avUnit: AVAudioUnit) -> [AudioUnitPreset] {
        guard let raw = avUnit.auAudioUnit.factoryPresets else { return [] }
        return raw.map { p in
            AudioUnitPreset(name: p.name, kind: .factory(number: p.number))
        }
    }

    // MARK: - User presets

    func userPresets() -> [AudioUnitPreset] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: storeURL, includingPropertiesForKeys: nil
        ) else { return [] }

        return urls
            .filter { $0.pathExtension == "aupreset" }
            .compactMap { url -> AudioUnitPreset? in
                guard let data = try? Data(contentsOf: url),
                      let envelope = try? JSONDecoder().decode(PresetEnvelope.self, from: data),
                      let classInfoData = Data(base64Encoded: envelope.classInfo) else { return nil }
                return AudioUnitPreset(
                    id: UUID(uuidString: envelope.id) ?? UUID(),
                    name: envelope.name,
                    kind: .user(classInfoData: classInfoData)
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func savePreset(name: String, from avUnit: AVAudioUnit) throws -> AudioUnitPreset {
        let classInfoData = try readClassInfo(from: avUnit)
        let id = UUID()
        let envelope = PresetEnvelope(
            id: id.uuidString,
            name: name,
            classInfo: classInfoData.base64EncodedString()
        )
        let fileData = try JSONEncoder().encode(envelope)
        let fileURL = storeURL.appendingPathComponent("\(id.uuidString).aupreset")
        try fileData.write(to: fileURL, options: .atomic)
        return AudioUnitPreset(id: id, name: name, kind: .user(classInfoData: classInfoData))
    }

    func deletePreset(_ preset: AudioUnitPreset) throws {
        let fileURL = storeURL.appendingPathComponent("\(preset.id.uuidString).aupreset")
        try FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Apply

    func applyPreset(_ preset: AudioUnitPreset, to avUnit: AVAudioUnit) throws {
        switch preset.kind {
        case .factory(let number):
            let auPreset = AUAudioUnitPreset()
            auPreset.number = number
            auPreset.name = preset.name
            avUnit.auAudioUnit.currentPreset = auPreset

        case .user(let classInfoData):
            let any = try PropertyListSerialization.propertyList(
                from: classInfoData,
                options: .mutableContainersAndLeaves,
                format: nil
            )
            var cfPlist: CFPropertyList = any as AnyObject
            let status = AudioUnitSetProperty(
                avUnit.audioUnit,
                kAudioUnitProperty_ClassInfo,
                kAudioUnitScope_Global,
                0,
                &cfPlist,
                UInt32(MemoryLayout<CFPropertyList>.size)
            )
            guard status == noErr else {
                throw AudioUnitPresetError.setPropertyFailed(status)
            }
        }
    }

    // MARK: - Private

    private func readClassInfo(from avUnit: AVAudioUnit) throws -> Data {
        // AudioUnitGetProperty returns a +1-retained CFPropertyList; use Unmanaged to handle ownership correctly.
        var plistRef: Unmanaged<CFPropertyList>? = nil
        var size = UInt32(MemoryLayout<Unmanaged<CFPropertyList>?>.size)
        let status = AudioUnitGetProperty(
            avUnit.audioUnit,
            kAudioUnitProperty_ClassInfo,
            kAudioUnitScope_Global,
            0,
            &plistRef,
            &size
        )
        guard status == noErr, let plist = plistRef?.takeRetainedValue() else {
            throw AudioUnitPresetError.getPropertyFailed(status)
        }
        return try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
    }

    // MARK: - Types

    private struct PresetEnvelope: Codable {
        let id: String
        let name: String
        let classInfo: String
    }
}

enum AudioUnitPresetError: LocalizedError {
    case getPropertyFailed(OSStatus)
    case setPropertyFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .getPropertyFailed(let s): return "Failed to read plugin state (OSStatus \(s))"
        case .setPropertyFailed(let s): return "Failed to apply plugin state (OSStatus \(s))"
        }
    }
}
