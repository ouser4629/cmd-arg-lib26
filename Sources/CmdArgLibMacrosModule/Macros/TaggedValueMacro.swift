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
import SwiftSyntaxMacros

public struct TaggedValuesMacro: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        if node.arguments.isEmpty {
            let code = "[]"
            return ExprSyntax("\(raw: code)")
        }
        var arrayElements = [ArrayElementSyntax]()
        for element in node.arguments {
            guard let tag = element.expression.as(DeclReferenceExprSyntax.self)?.baseName.text else {
                continue
            }
            let code = #""\#(tag): \(\#(tag))""#
            arrayElements.append( ArrayElementSyntax( expression: ExprSyntax("\(raw: code)"), trailingComma: .commaToken()))
        }
        let arrayLiteral = ArrayExprSyntax(elements: ArrayElementListSyntax(arrayElements))
        return ExprSyntax(arrayLiteral)
    }
}
