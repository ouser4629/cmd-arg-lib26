## Setup

This file shows how to run the examples included with cmd-arg-lib and
how to use cmd-arg-lib in s separate project.

## Running the Examples

Move to a convenient folder, say, Temp.

Clone this repository

```
Temp> git clone "https://github.com/ouser4629/cmd-arg-lib26.git"
```

Build the package:

```
Temp> cd cmd-arg-lib26
swift build -c release
```

Switch to a new tab (command T) and list the examples:

```
cd .build/release
release> ls -lF | grep '*'
```

Run some commands:

```
./mf0-print --help
./mf0-print -i "Hi Manny"
./mf1-greet --help
./mf1-greet -iuc1 -p arrow Manny
```


## Using Command Argument Library

This shows how to build and run Example2, starting from scratch.

### Create the package

Make a new folder named Greet in, say, Temp.

```
Temp> mkdir Greet
Temp> cd Greet/
Greet> swift package init --type executable
```

Open the package in an editor.

Replace the contents of Package.swift with:

```Swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Greet",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "mf1-greet", targets: ["Greet"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ouser4629/cmd-arg-lib26.git", from: "0.1.0")
    ],

    targets: [
        .executableTarget(
            name: "Greet",
            dependencies: [
                .product(name: "CmdArgLib", package: "cmd-arg-lib26"),
                .product(name: "CmdArgLibMacros", package: "cmd-arg-lib26"),
            ]
        ),
    ]
)
```

 Replace the contents of Greet/Sources/Greet/Greet.swift with the content of cmd-art-lib26/Sources/Example2/Greet.swift
 
 ### Build and run the package
 
 In the terminal run this:
 
```
 Greet> swift build -c release
``` 

Switch to a new tab (command T), go to the release folder and list the executables

```
Greet> cd .build/release
release> ls -1F | grep '*'
CmdArgLibMacrosModule-tool*
mf1-greet*
```

Try some command calls in the "release tab":

```
release> ./mf1-greet -h

release> ./mf1-greet -iu -p arrow Manny

./mf1-greet -iu -c3 -p arrow Manny
```

### Edit, Build and Run

Open the editor and rename the parameter "upper" to "uppercase".
Return to the "build tab" in terminal and build.
Move to the release tab in terminal and run.

### Clean and Run

Occationally you might have to clear the build folder.

In the terminal, close the release tab and, in the build tab, run:

```
rm -rf .build .swiftpm
swift build -c release
```
Switch to a new tab (command T) and go to the release folder:

```
cd .build/release
```

Run some commands
