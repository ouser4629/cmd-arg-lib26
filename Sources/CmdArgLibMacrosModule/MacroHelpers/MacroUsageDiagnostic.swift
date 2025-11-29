// Copyright (c) 2025 Peter Summerland
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Used to make a diagnostic  messages and diagnostics
struct MacroUsageDiagnosticMessage: DiagnosticMessage {

    let message: String
    let diagnosticID: SwiftDiagnostics.MessageID
    let severity: SwiftDiagnostics.DiagnosticSeverity

    init(
        message: String,
        diagnosticID: MessageID = MessageID(domain: "CmdArgLib", id: "MacroUsageError"),
        severity: DiagnosticSeverity = .error
    ) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }

    func diagnostic<Node: SyntaxProtocol>(
        node: Node,
        position: AbsolutePosition? = nil,
        highlights: [Syntax]? = nil,
        notes: [Note] = [],
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        let diagnostic = Diagnostic(
            node: node, position: position, message: self, highlights: highlights, notes: notes,
            fixIts: fixIts)
        return diagnostic
    }
}
