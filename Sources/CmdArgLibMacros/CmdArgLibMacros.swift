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

/// Generate a peer function that can  invoked  by the operating system with  command line parameters.
/// - Parameters:
///   - shadowGroups: Names of parameters that shadow each other (last one wins)
@attached(peer, names: named(main))
public macro MainFunction(
    shadowGroups: [String] = []
) = #externalMacro(module: "CmdArgLibMacrosModule", type: "MainFunctionMacro")

/// --------------------------------------------------------------------------------------------------

/// Generate a peer function that can  be called  with a command argument list
/// - Parameters:
///   - shadowGroups: Names of parameters that shadow each other (last one wins)
@attached(peer, names: named(call))
public macro CallFunction(
    shadowGroups: [String] = []
) = #externalMacro(module: "CmdArgLibMacrosModule", type: "CallFunctionMacro")

/// --------------------------------------------------------------------------------------------------

/// Generate a peer functions for use with StatefulCommand<T> and SimpleCommands
/// - Parameters:
///   - shadowGroups: Names of parameters that shadow each other (last one wins)
///
///The peer functions are:
///  1. action, which confroms to StatefulCommandAction
///  2. actionConfig, which returns the instance of PeerFunctionConfig corresponding to action
///
///If the work function does not have paretnt, state as last two parameters, they will be sythesized in the
///wrapping funcion with type T (suitable for Command<T>.
///  1. if the work funcition returns something, it  must be [T]
///  2. If the work function returns nothing, T will be Void.

@attached(peer, names: named(action), named(actionConfig))
public macro CommandAction(
    shadowGroups: [String] = []
) = #externalMacro(module: "CmdArgLibMacrosModule", type: "CommandActionMacro")

/// Print expresion and value
@freestanding(expression)
public macro taggedValues(_ value: Any...) -> [String] = #externalMacro(module: "CmdArgLibMacrosModule", type: "TaggedValuesMacro")
