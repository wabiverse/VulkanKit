// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "VulkanKit",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "VulkanKit",
      targets: ["VulkanKit"]
    ),
    .library(
      name: "KHRONOS",
      targets: ["KHRONOS"]
    ),
    .library(
      name: "etcdec",
      targets: ["etcdec"]
    ),
    .library(
      name: "astcencoder",
      targets: ["astcencoder"]
    ),
    .library(
      name: "basisu",
      targets: ["basisu"]
    ),
    .library(
      name: "libzstd",
      targets: ["libzstd"]
    ),
    .library(
      name: "GL",
      targets: ["GL"]
    ),
    .library(
      name: "dfdutils",
      targets: ["dfdutils"]
    ),
    .library(
      name: "libktx",
      targets: ["libktx"]
    ),
    .library(
      name: "glm",
      targets: ["glm"]
    ),
    .library(
      name: "stb_image",
      targets: ["stb_image"]
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
        .target(name: "vulkan"),
        .target(name: "libktx")
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ]
    ),
    .target(
      name: "KHRONOS"
    ),
    .target(
      name: "astcencoder",
      dependencies: [
        .target(name: "stb_image")
      ],
      publicHeadersPath: "."
    ),
    .target(
      name: "basisu",
      dependencies: [
        .target(name: "libzstd"),
      ],
      cxxSettings: [
        .define("LIBKTX", to: "1"),
        .define("BASISU_SUPPORT_OPENCL", to: "0")
      ]
    ),
    .target(
      name: "dfdutils",
      dependencies: [
        .target(name: "KHRONOS"),
      ],
      cxxSettings: [
        .headerSearchPath("."),
        .headerSearchPath("vulkan")
      ]
    ),
    .target(
      name: "libzstd"
    ),
    .target(
      name: "GL"
    ),
    .target(
      name: "etcdec"
    ),
    .target(
      name: "libktx",
      dependencies: [
        .target(name: "libzstd"),
        .target(name: "GL"),
        .target(name: "KHRONOS"),
        .target(name: "etcdec"),
        .target(name: "dfdutils"),
        .target(name: "astcencoder"),
        .target(name: "basisu"),
        .target(name: "vulkan")
      ],
      cxxSettings: [
        .headerSearchPath("."),
        .define("LIBKTX", to: "1"),
        .define("KTX_FEATURE_WRITE", to: "1"),
        .define("BASISU_SUPPORT_OPENCL", to: "0")
      ]
    ),
    .target(
      name: "glm"
    ),
    .target(
      name: "stb_image"
    ),
    .target(
      name: "glTF",
      dependencies: [
        .target(name: "stb_image")
      ]
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
        .target(name: "glTF"),
        .target(name: "glm")
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ]
    ),
  ],
  cxxLanguageStandard: .cxx17
)
