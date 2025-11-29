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
import SwiftSyntax
import SwiftDiagnostics

func makeParameterInfo(_ syntax: FunctionParameterSyntax) -> (WorkFunctionParameterInfo, [Diagnostic]) {
    var typeName = syntax.type.trimmedDescription
    var parameterName = syntax.firstName.trimmedDescription
    let labelName = parameterName
    if let secondName = syntax.secondName?.trimmedDescription {
        parameterName = secondName
    }
    var errorMsgs = [String]()
    let defaultValue = syntax.defaultValue?.value.trimmedDescription ?? "nil"
    if let elementType = syntax.type.as(ArrayTypeSyntax.self)?.element.trimmedDescription {
        typeName = "Array<\(elementType)>"
    }
    else if let typeName = syntax.type.as(IdentifierTypeSyntax.self)?.trimmedDescription {
        if typeName == "Flag" &&  defaultValue == "true" {
            errorMsgs.append(
                "The parameter '\(parameterName)' has a default value of 'true', which is not allowed for flags")
        }
        if (typeName == "MetaFlag" || typeName == "MetaFlag") && defaultValue == "nil" {
            errorMsgs.append(
                "The parameter '\(parameterName)', is missing its required default value")
        }
        if (typeName == "Flag" || typeName == "MetaFlag") && labelName == "_" {
            errorMsgs.append(
                "The parameter '\(parameterName)', a \(typeName), must have a label")
        }
    }
    else if syntax.type.as(OptionalTypeSyntax.self) != nil {
        if defaultValue != "nil" {
            errorMsgs.append(
                "The parameter '\(parameterName)' has a non-nil default value, which is not allowed for optional types"
            )
        }
    }
    if typeName.hasPrefix("Array<") && !(defaultValue == "[]" || defaultValue == "nil") {
        errorMsgs.append(
            "The parameter '\(parameterName)' has a default value, other than '[]', which is not allowed for arrays")
    }
    if typeName.hasPrefix("Variadic<") && !(defaultValue == "[]" || defaultValue == "nil") {
        errorMsgs.append(
            "The parameter '\(parameterName)' has a default value, other than '[]', which is not allowed for variadics")
    }
    let diagnostics = errorMsgs.map{MacroUsageDiagnosticMessage(message: $0).diagnostic(node: syntax)}
    let parameterInfo = WorkFunctionParameterInfo(
        name: parameterName,
        parameterLabel: labelName,
        typeName: typeName,
        defaultValue: syntax.defaultValue?.value.trimmedDescription)
    return (parameterInfo, diagnostics)
}
