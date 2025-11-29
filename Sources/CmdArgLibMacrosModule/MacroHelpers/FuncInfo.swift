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

struct FuncInfo: FuncInfoProtocol {
    let name: String
    let callName: String
    let genericParameterClause: String
    let modifiers: String  // e.g., public static
    let mainFunctionReturnEffects: String  // e.g., async (never throws)
    let runFunctionReturnEffects: String  // always throws (due to parsing)
    let commandActionReturnEffects: String
    let returnType: String
    let returnPrefix: String
    let callModifiers: String  // e.g., try await
    let wrappedFunctionThrows: Bool
    var parameterInfos: [WorkFunctionParameterInfo]
    var stateType: String?
    var synthesizedStateType: Bool

    init(
        name: String, callName: String, genericParameterClause: String, modifiers: String,
        mainFunctionReturnEffects: String, runFunctionReturnEffects: String, commandActionReturnEffects: String,
        returnType: String, returnPrefix: String, callModifiers: String, wrappedFunctionThrows: Bool,
        parameterInfos: [WorkFunctionParameterInfo], stateType: String? = nil, synthesizedStateType: Bool
    ) {
        self.name = name
        self.callName = callName
        self.genericParameterClause = genericParameterClause
        self.modifiers = modifiers
        self.mainFunctionReturnEffects = mainFunctionReturnEffects
        self.runFunctionReturnEffects = runFunctionReturnEffects
        self.commandActionReturnEffects = commandActionReturnEffects
        self.returnType = returnType
        self.returnPrefix = returnPrefix
        self.callModifiers = callModifiers
        self.wrappedFunctionThrows = wrappedFunctionThrows
        self.parameterInfos = parameterInfos
        self.stateType = stateType
        self.synthesizedStateType = synthesizedStateType
    }
}

func makeFuncInfo(funcSyntax: FunctionDeclSyntax) -> (FuncInfo, [String: String], [Diagnostic]) {
    let modifiers = funcSyntax.modifiers.trimmedDescription
    let name = funcSyntax.name.trimmedDescription
    let callName = snake(name, "-")
    let signature = funcSyntax.signature
    let wrappedFunctionEffects = signature.effectSpecifiers?.trimmedDescription ?? ""
    let genericParameterClause = funcSyntax.genericParameterClause?.trimmedDescription ?? ""

    let parameterListSyntax = signature.parameterClause.parameters
    var parameterInfos: [WorkFunctionParameterInfo] = []
    var parameterInfoNodePairs: [(WorkFunctionParameterInfo, FunctionParameterSyntax)] = []
    var diagnostics: [Diagnostic] = []
    for parameterSyntax in parameterListSyntax {
        let (parameterInfo, diagnostic) = makeParameterInfo(parameterSyntax)
        parameterInfos.append(parameterInfo)
        parameterInfoNodePairs.append((parameterInfo, parameterSyntax))
        diagnostics.append(contentsOf: diagnostic)
    }
    if name.hasPrefix("__") && name.hasSuffix("__a") {
        let message = #"Wrapped function names starting with "__" cannot end with "__""#
        diagnostics.append(MacroUsageDiagnosticMessage(message: message).diagnostic(node: funcSyntax))
    }
    let (labelTripleDict, labelDiagnostics) = makeLabelTripleDict(parameterInfoNodePairs, funcNode: funcSyntax)
    diagnostics += labelDiagnostics

    var stateType: String? = nil
    if let lastParameterInfo = parameterInfos.last, lastParameterInfo.name == "state" {
        stateType = TypeGroup.CmdArgLibValueTypeName(typeName: lastParameterInfo.typeName)
    }
    var mainFuntionReturnEffects = wrappedFunctionEffects  // e.g., async - but never throws
    var callFunctionReturnEffects = wrappedFunctionEffects  // always throws
    let wrappedFunctionThrows = wrappedFunctionEffects.contains("throws")
    if wrappedFunctionThrows {
        mainFuntionReturnEffects = wrappedFunctionEffects.replacingOccurrences(of: "throws", with: "")
    } else {
        callFunctionReturnEffects.append(" throws")
    }
    var returnType = signature.returnClause?.type.trimmedDescription ?? ""
    if returnType == "Void" { returnType = "" }
    let returnPrefix = returnType.isEmpty ? "" : "newState__CommandArgumentLibrary = "
    var callModifiers = ""
    if wrappedFunctionEffects.contains("throws") {
        callModifiers += "try "
    }
    if wrappedFunctionEffects.contains("async") {
        callModifiers += "await "
    }

    let funcInfo = FuncInfo(
        name: name,
        callName: callName,
        genericParameterClause: genericParameterClause,
        modifiers: modifiers,
        mainFunctionReturnEffects: mainFuntionReturnEffects,
        runFunctionReturnEffects: callFunctionReturnEffects,
        commandActionReturnEffects: callFunctionReturnEffects,
        returnType: returnType,
        returnPrefix: returnPrefix,
        callModifiers: callModifiers,
        wrappedFunctionThrows: wrappedFunctionThrows,
        parameterInfos: parameterInfos,
        stateType: stateType,
        synthesizedStateType: false,
    )
    return (funcInfo, labelTripleDict, diagnostics)
}
