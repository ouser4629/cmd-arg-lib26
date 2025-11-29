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

func setup(
    with node: AttributeSyntax,
    and funcSyntax: FunctionDeclSyntax
) ->(FuncInfo?, NameLabelTripleDict, Code?, [Diagnostic]) {
    var funcInfo: FuncInfo
    let nameLableTripleDict: [String:String]
    var diagnostics: [Diagnostic]
    (funcInfo, nameLableTripleDict, diagnostics) = makeFuncInfo(funcSyntax: funcSyntax)
    let (configCode, configDiagnostics) = makeConfigCode(funcInfo.parameterInfos, node)
    diagnostics += configDiagnostics
    return (funcInfo, nameLableTripleDict, configCode, diagnostics)
}

func ensureFuncSyntax(_ declaration: some DeclSyntaxProtocol, _ context: MacroExpansionContext) -> FunctionDeclSyntax?
{
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
        let errorMsg = ("Only applies to functions")
        let msg = MacroUsageDiagnosticMessage(message: errorMsg)
        context.diagnose(msg.diagnostic(node: declaration))
        return nil
    }
    return funcDecl
}
