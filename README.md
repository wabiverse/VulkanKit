<!-- markdownlint-configure-file {
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": false,
  "MD041": false
} -->

<div align="center">

<h1 align="center">
  <img width="150" src="vulkan.svg">
</h1>

<p align="center">
  <i align="center"><b>swift wrapper</b> around <b>vulkan</b>.</i>
</p>

</div>

<h3 align="center">
  <p align="center">Documented Swift API</p>
</h3>

```swift
import VulkanKit

print("major:", Vulkan.Version.major.rawValue) // major: 1
print("minor:", Vulkan.Version.minor.rawValue) // minor: 3
print("patch:", Vulkan.Version.patch.rawValue) // patch: 283

print("Vulkan Instance Version:", Vulkan.Version.description)
// Vulkan Instance Version: 1.3.283
```

<h3 align="center">
  <p align="center">Using VulkanKit</p>
</h3>

```swift
// swift-tools-version:5.10
import PackageDescription

let package = Package(
  name: "MyVulkanPackage",
  products: [
    .library(
      name: "MyVulkanLibrary",
      targets: ["MyVulkanLibrary"]
    )
  ],
  dependencies: [
    // add VulkanKit as a package dependency.
    .package(url: "https://github.com/wabiverse/VulkanKit.git", branch: "main")
  ],
  targets: [
    .target(
      name: "MyVulkanLibrary",
      dependencies: [
        // add the VulkanKit product as a target dependency.
        .product(name: "VulkanKit", package: "VulkanKit")
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ]
    )
  ]
)
```
