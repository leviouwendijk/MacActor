import Foundation

public enum AppleScriptResult {
    case success(String)
    case failure(String)
}

public struct AppleScriptRunner {
    public static func run(script: String, silent: Bool = false) -> AppleScriptResult {
        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]
        
        let output = Pipe()
        let error = Pipe()
        process.standardOutput = output
        process.standardError = error
        
        do {
            try process.run()
            process.waitUntilExit()
            let outputStr = String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let errorStr = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            
            if process.terminationStatus == 0 {
                if !silent { print(outputStr) }
                return .success(outputStr)
            } else {
                if !silent { print(errorStr) }
                return .failure(errorStr)
            }
        } catch {
            return .failure("Failed to run AppleScript: \(error)")
        }
    }
}

public struct AppleScriptVariables {
    public var filePath: String?
    public var exportPath: String?
    public var additional: [String: String] = [:]
    
    public init(
        filePath: String? = nil,
        exportPath: String? = nil,
        additional: [String: String] = [:]
    ) {
        self.filePath = filePath
        self.exportPath = exportPath
        self.additional = additional
    }
}

public enum TargetApplication: String {
    case numbers = "Numbers"
    case ghostty = "Ghostty"
    case finder = "Finder"
}

public enum GenericAppleScriptComponent: String {
    case activate
    case open
    case close
    case exportPDF
    case exportCSV
    case displayDialog
    case numbersMap
    
    public func resolve(for app: TargetApplication, using variables: AppleScriptVariables = .init()) -> String {
        switch self {
        case .activate:
            return """
            tell application "\(app.rawValue)"
                activate
            end tell
            """
        case .open:
            guard let file = variables.filePath else { return "// Missing filePath" }
            return """
            set docFile to POSIX file "\(file)" as alias
            tell application "\(app.rawValue)"
                open docFile
            end tell
            """
        case .close:
            return """
            tell application "\(app.rawValue)"
                tell document 1
                    close
                end tell
            end tell
            """
        case .exportPDF:
            guard let export = variables.exportPath else { return "// Missing exportPath" }
            return """
            set pdfPath to POSIX file "\(export)"
            tell application "\(app.rawValue)"
                tell document 1
                    export to pdfPath as PDF
                end tell
            end tell
            """
        case .exportCSV:
            guard let export = variables.exportPath else { return "// Missing exportPath" }
            return """
            set csvPath to POSIX file "\(export)"
            tell application "\(app.rawValue)"
                tell document 1
                    export to csvPath as CSV
                end tell
            end tell
            """
        case .displayDialog:
            let message = variables.additional["message"] ?? "No message"
            return """
            display dialog "\(message)"
            """
        case .numbersMap:
            return """
            tell document 1
                set result to "Sheet and Table Overview:\n"
                repeat with sheetIndex from 1 to count of sheets
                    set currentSheet to sheet sheetIndex
                    set sheetName to name of currentSheet
                    set result to result & "Sheet " & sheetIndex & ": " & sheetName & "\n"

                    repeat with tableIndex from 1 to count of tables of currentSheet
                        set currentTable to table tableIndex of currentSheet
                        set tableName to name of currentTable
                        set result to result & "  Table " & tableIndex & ": " & tableName & "\n"
                    end repeat
                end repeat
                display dialog result
            end tell
            """
        }
        
    }
}

public struct ConstructedAppleScript {
    public let application: TargetApplication
    public let components: [GenericAppleScriptComponent]
    public let variables: AppleScriptVariables

    public init(application: TargetApplication, components: [GenericAppleScriptComponent], variables: AppleScriptVariables = .init()) {
        self.application = application
        self.components = components
        self.variables = variables
    }

    public func buildScript() -> String {
        return components.map { $0.resolve(for: application, using: variables) }
                         .joined(separator: "\n")
    }

    public func run(silent: Bool = false) -> AppleScriptResult {
        let script = buildScript()
        return AppleScriptRunner.run(script: script, silent: silent)
    }
}
