import Foundation

public struct NumbersCellTarget {
    public let sheet: String
    public let table: String
    public let row: String
    public let column: String
    public let value: String
}

public struct NumbersActor {
    public let application: TargetApplication = .numbers

    public init() { }

    public func activate() -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.activate]
        )
        return script.run(silent: false)
    }

    public func openDocument(filePath: String) -> AppleScriptResult {
        let variables = AppleScriptVariables(filePath: filePath)
        let script = ConstructedAppleScript(
            application: application,
            components: [.open],
            variables: variables
        )
        return script.run(silent: false)
    }

    public func exportPDF(to exportPath: String) -> AppleScriptResult {
        let variables = AppleScriptVariables(exportPath: exportPath)
        let script = ConstructedAppleScript(
            application: application,
            components: [.exportPDF],
            variables: variables
        )
        return script.run(silent: false)
    }

    public func exportCSV(to exportPath: String) -> AppleScriptResult {
        let variables = AppleScriptVariables(exportPath: exportPath)
        let script = ConstructedAppleScript(
            application: application,
            components: [.exportCSV],
            variables: variables
        )
        return script.run(silent: false)
    }

    public func closeDocument() -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.close]
        )
        return script.run(silent: false)
    }

    public func mapSheetsAndTables() -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.open, .activate, .numbersMap, .endTell]
        )
        let built = script.buildScript()
        print(built)
        return script.run(silent: false)
    }

    public func setCellValue(_ appleScriptVariables: AppleScriptVariables) -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.numbersCell],
            variables: appleScriptVariables
        )
        return script.run(silent: false)
    }
}
