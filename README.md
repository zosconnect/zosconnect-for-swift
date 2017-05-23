[![Build Status](https://travis-ci.org/zosconnect/zosconnect-for-swift.svg?branch=master)](https://travis-ci.org/zosconnect/zosconnect-for-swift)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [z/OS&reg; Connect for Swift](#zos&reg-connect-for-swift)
  - [Installing](#installing)
  - [Usage](#usage)
    - [Connecting](#connecting)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## z/OS&reg; Connect for Swift

A Swift package for working with APIs and Services managed by z/OS Connect Enterprise Edition (EE).

### Installing

Add the following to the `dependencies` array in your `Package.swift`.

```swift
.Package(url: "https://github.com/zosconnect/zosconnect-for-swift", majorVersion: 0, minor: 3)
```

### Usage

Create an instance of the ZosConnect object passing in the URI of the z/OS Connect EE server.

```swift
let zosConnect = ZosConnect(uri: "http://example.com:9080")
```

This object provides functions for retrieving a list of Services and APIs and getting an individual Service or API by name.

The Service and API objects then provide functions to work with those artefacts. The documentation provides more information on using these functions.

### License

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
