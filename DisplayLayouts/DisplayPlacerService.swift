import Foundation

enum DisplayPlacerError: Error, LocalizedError {
    case toolNotFound
    case runFailed(String)
    case parseFailed

    var errorDescription: String? {
        switch self {
        case .toolNotFound: return "displayplacer tool not found in app bundle"
        case .runFailed(let s): return "displayplacer failed: \(s)"
        case .parseFailed: return "Could not parse current layout from displayplacer output"
        }
    }
}

enum ApplyOutcome {
    case success
    case partial(missingDisplays: [String])
    case failure(String)
}

final class DisplayPlacerService {
    private var toolURL: URL? {
        // Preferred path: Contents/Resources/Tools/displayplacer
        if let base = Bundle.main.resourceURL {
            let preferred = base.appendingPathComponent("Tools/displayplacer")
            if FileManager.default.fileExists(atPath: preferred.path) {
                return preferred
            }
            // Fallback: if accidentally copied as a plain resource
            let atRoot = base.appendingPathComponent("displayplacer")
            if FileManager.default.fileExists(atPath: atRoot.path) {
                return atRoot
            }
        }
        return nil
    }

    func captureCurrentArgs() -> Result<[String], Error> {
        guard let tool = toolURL else { return .failure(DisplayPlacerError.toolNotFound) }
        let result = run(tool: tool, arguments: ["list"]) 
        if result.code != 0 { return .failure(DisplayPlacerError.runFailed(result.err.isEmpty ? result.out : result.err)) }
        // Find the line that starts with 'displayplacer '
        guard let line = result.out.components(separatedBy: .newlines).first(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("displayplacer ") }) else {
            return .failure(DisplayPlacerError.parseFailed)
        }
        // Extract quoted segments: "..." per-display argument
        let regex = try! NSRegularExpression(pattern: "\"([^\"]+)\"", options: [])
        let nsLine = line as NSString
        let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
        let args = matches.map { nsLine.substring(with: $0.range(at: 1)) }
        guard !args.isEmpty else { return .failure(DisplayPlacerError.parseFailed) }
        return .success(args)
    }

    func apply(args: [String]) -> ApplyOutcome {
        guard let tool = toolURL else { return .failure(DisplayPlacerError.toolNotFound.localizedDescription) }
        let res = run(tool: tool, arguments: args)
        let combined = (res.out + "\n" + res.err).trimmingCharacters(in: .whitespacesAndNewlines)
        let missing = extractMissingDisplays(from: combined)
        if res.code == 0 {
            return missing.isEmpty ? .success : .partial(missingDisplays: missing)
        } else {
            // Treat missing displays as partial success, otherwise surface failure text
            return missing.isEmpty ? .failure(combined.isEmpty ? "displayplacer failed" : combined) : .partial(missingDisplays: missing)
        }
    }

    private func extractMissingDisplays(from text: String) -> [String] {
        // Matches: Unable to find screen <UUID>
        let pattern = #"Unable to find screen\s+([A-F0-9\-]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let ns = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: ns.length))
        let uuids = matches.map { ns.substring(with: $0.range(at: 1)) }
        return Array(Set(uuids)).sorted()
    }

    private struct CommandResult { let code: Int32; let out: String; let err: String }

    private func run(tool: URL, arguments: [String]) -> CommandResult {
        let process = Process()
        process.executableURL = tool
        process.arguments = arguments

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        do { try process.run() } catch {
            return CommandResult(code: 1, out: "", err: error.localizedDescription)
        }
        process.waitUntilExit()
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let err = String(data: errData, encoding: .utf8) ?? ""
        return CommandResult(code: process.terminationStatus, out: out, err: err)
    }
}
