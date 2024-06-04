// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "VulkanKit",
  products: [
    .library(
      name: "VulkanKit",
      targets: ["VulkanKit"]
    ),
    .library(
      name: "glTF",
      targets: ["glTF"]
    ),
    .executable(
      name: "VulkanKitDemo",
      targets: ["VulkanKitDemo"]
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "VulkanKit",
      dependencies: [
        .target(name: "vulkan")
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ]
    ),
    .target(
      name: "glTF"
    ),
    .systemLibrary(
      name: "vulkan",
      pkgConfig: "vulkan",
      providers: [
        .apt(["libvulkan-dev"]),
        .yum(["vulkan-devel"]),
        .brew(["vulkan"]),
      ]
    ),
    .executableTarget(
      name: "VulkanKitDemo",
      dependencies: [
        .target(name: "VulkanKit"),
        .target(name: "glTF")
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ]
    ),
  ]
)