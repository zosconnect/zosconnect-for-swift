import PackageDescription

let package = Package(
    name: "zosconnectforswift",
    targets: [],
    dependencies: [
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON", versions: Version(1,0,0)..<Version(15, .max, .max)),
      .Package(url: "https://github.com/IBM-Swift/Kitura-net",
          majorVersion: 1, minor: 3),
    ]
)
