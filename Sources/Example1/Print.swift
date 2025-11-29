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

// Example_0_Pring - A minimal example for use in Cmd_Arg_Lib's README.md

import CmdArgLib
import CmdArgLibMacros

@main
struct Print {
    
    private static let showElements: [ShowElement] = [
        .text("DESCRIPTION:", "Print a greeting."),
        .synopsis("\nUSAGE:"),
        .text("\nPARAMETERS:"),
        .parameter("showIndex","Show the index of each repetition"),
        .parameter("upper","Uppercase the phrase"),
        .parameter("phrase", "The phrase to print."),
        .parameter("count", "The number of times to print the phrase (default: 1)."),
        .parameter("help", "Show this help message.")
    ]
    
    /// Print a phrase count times, optionally uppercased or with an index.
    @MainFunction
    private static func mf0Print(
        i showIndex: Flag,
        u upper: Flag,
        count: Int = 1,
        _ phrase: String,
        h__help help: MetaFlag = MetaFlag(helpElements: showElements))
    {
        for index in 0..<max(count, 1) {
            var line = showIndex ? "  \(index + 1). \(phrase)" : "  \(phrase)"
            if upper { line = line.uppercased() }
            print(line)
        }
    }
}
