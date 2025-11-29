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

func ensureParentState(funcInfo: FuncInfo?, funcSyntax: FunctionDeclSyntax) -> (FuncInfo?, [Diagnostic]) {
    guard let funcInfo = funcInfo else {
       return (nil, [])
    }
    let funcInfoparameterInfos = funcInfo.parameterInfos
    if let stateType = funcInfo.stateType {
        let parameterInfos = funcInfoparameterInfos.dropLast()
        // Non-void state type
        var usageErrors: [String] = []
        if let parentInfo = parameterInfos.last,
           parentInfo.name == "nodePath",
           parentInfo.typeName == "Array<StatefulCommand<\(stateType)>>"
        {
            let expectedReturnType = "[\(stateType)]"
            if !funcInfo.returnType.isEmpty && funcInfo.returnType != expectedReturnType {
                usageErrors.append("Return type mismatch: expected '\(expectedReturnType)'")
            }
        } else {
            usageErrors.append("Penultimate parameter must be 'nodePath: [StatefulCommand<\(stateType)>]'")
        }
        var diagnostics: [Diagnostic] = []
        for usageError in usageErrors {
            let msg = MacroUsageDiagnosticMessage(message: usageError)
            diagnostics.append(msg.diagnostic(node: funcSyntax))
        }
        return (funcInfo, diagnostics)
    } else {
        // set up for void state
        var stateType = "Void"
        var errorMessage: String?
        var parameterInfos = funcInfoparameterInfos
        if (parameterInfos.contains { $0.name == "nodePath" }) {
            errorMessage = "Work function has parameter named 'nodePath', but none named 'state'"
        }
        else {
            let returnType = funcInfo.returnType
            if !returnType.isEmpty {
                let regex = /\[(.+)]/
                if let match = try? regex.firstMatch(in: returnType) {
                    stateType = String(match.1)
                } else {
                    errorMessage = "Return type must be an array."
                }
            }
        }
        if let errorMessage {
            let msg = MacroUsageDiagnosticMessage(message: errorMessage)
            let diagnostics: [Diagnostic] = [msg.diagnostic(node: funcSyntax)]
            return (funcInfo, diagnostics)
        }


        let parentsParameterInfo = WorkFunctionParameterInfo(name: "nodePath", typeName: "Array<StatefulCommand<\(stateType)>>")
        let stateParameterInfo = WorkFunctionParameterInfo(name: "state", typeName: "[\(stateType)]")
        parameterInfos.append(parentsParameterInfo)
        parameterInfos.append(stateParameterInfo)
        var newFuncInfo = funcInfo
        newFuncInfo.parameterInfos = parameterInfos
        newFuncInfo.stateType = stateType
        newFuncInfo.synthesizedStateType = true
        return ensureParentState(funcInfo: newFuncInfo, funcSyntax: funcSyntax)
    }
}
