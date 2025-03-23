import Foundation

public struct NumbersActor {
    public let application: TargetApplication = .numbers

    public init() { }

    /// Activate the Numbers app.
    public func activate() -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.activate]
        )
        return script.run(silent: false)
    }

    /// Open a Numbers document at a given file path.
    public func openDocument(filePath: String) -> AppleScriptResult {
        let variables = AppleScriptVariables(filePath: filePath)
        let script = ConstructedAppleScript(
            application: application,
            components: [.open],
            variables: variables
        )
        return script.run(silent: false)
    }

    /// Export the currently open document as a PDF to a given export path.
    public func exportPDF(to exportPath: String) -> AppleScriptResult {
        let variables = AppleScriptVariables(exportPath: exportPath)
        let script = ConstructedAppleScript(
            application: application,
            components: [.exportPDF],
            variables: variables
        )
        return script.run(silent: false)
    }

    /// Export the currently open document as CSV to a given export path.
    public func exportCSV(to exportPath: String) -> AppleScriptResult {
        let variables = AppleScriptVariables(exportPath: exportPath)
        let script = ConstructedAppleScript(
            application: application,
            components: [.exportCSV],
            variables: variables
        )
        return script.run(silent: false)
    }

    /// Close the currently open Numbers document.
    public func closeDocument() -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.close]
        )
        return script.run(silent: false)
    }

    /// Map and display all sheets and tables in the current Numbers document.
    public func mapSheetsAndTables() -> AppleScriptResult {
        let script = ConstructedAppleScript(
            application: application,
            components: [.numbersMap]
        )
        return script.run(silent: false)
    }

    /// Set the value of a cell (using row/column indexing) in a specified sheet and table.
    public func setCellValue(sheet: Int, table: String, row: Int, column: Int, value: String) -> AppleScriptResult {
        let script = """
        tell application "\(TargetApplication.numbers.rawValue)"
            activate
            tell document 1
                tell sheet \(sheet)
                    tell table "\(table)"
                        set the value of cell \(column) of row \(row) to "\(value)"
                    end tell
                end tell
            end tell
        end tell
        """
        return AppleScriptRunner.run(script: script, silent: false)
    }
}
