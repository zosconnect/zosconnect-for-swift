import PackageDescription

#if os(Linux)
   let swiftyJsonUrl = "https://github.com/IBM-Swift/SwiftyJSON.git"
   let swiftyJsonVersion = 3
#else
   let swiftyJsonUrl = "https://github.com/SwiftyJSON/SwiftyJSON.git"
   let swiftyJsonVersion = 2
#endif

let package = Package(
    name: "zosconnectforswift",
    targets: [],
    dependencies: [
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 7),
      .Package(url: "https://github.com/IBM-Swift/Kitura-net",
          majorVersion: 0, minor: 13),
    ]
)
