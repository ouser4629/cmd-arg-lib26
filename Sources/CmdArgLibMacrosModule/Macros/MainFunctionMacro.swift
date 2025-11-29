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

import CmdArgLibMacroSupport
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

typealias Code = String
typealias Name = String
typealias NameLabelTripleDict = [String:String]

public struct MainFunctionMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    )
    throws -> [SwiftSyntax.DeclSyntax]
    {
        guard let funcSyntax = ensureFuncSyntax(declaration, context) else { return [] }
        let (funcInfo, nameLableTripleDict, maybeConfigCode, setupDiagnostics) = setup(with: node, and: funcSyntax)
        var diagnostics = setupDiagnostics
        if let funcInfo, !(funcInfo.returnType.isEmpty || funcInfo.returnType == "Void") {
            let message = "Functions annotated with @MainFunction cannot have return values."
            diagnostics.append(MacroUsageDiagnosticMessage(message: message).diagnostic(node: funcSyntax))
        }
        guard let configCode = maybeConfigCode, diagnostics.isEmpty else {
            for diagnostic in diagnostics { context.diagnose(diagnostic) }
            return []
        }
        let code = makeMainFunctionCode(configCode, funcInfo!, nameLableTripleDict)
        return [DeclSyntax("\(raw: code)")]
    }
}
