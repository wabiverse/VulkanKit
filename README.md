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

<sub>
  <h3 align="center">
    <p align="center">Documented Swift API</p>
  </h3>
</sub>

<sup>
  <h5 align="center">
    <p align="center">from the top...</p>
  </h5>
</sup>

```swift
import VulkanKit

print("major:", Vulkan.Version.major.rawValue) // major: 1
print("minor:", Vulkan.Version.minor.rawValue) // minor: 3
print("patch:", Vulkan.Version.patch.rawValue) // patch: 283

print("Vulkan Instance Version:", Vulkan.Version.description)
// Vulkan Instance Version: 1.3.283

let vgi = Vulkan.GI()
vgi.initVulkan()
// available vulkan extensions:
// extension [1 of 17]: VK_KHR_device_group_creation
// extension [2 of 17]: VK_KHR_external_fence_capabilities
// extension [3 of 17]: VK_KHR_external_memory_capabilities
// extension [4 of 17]: VK_KHR_external_semaphore_capabilities
// extension [5 of 17]: VK_KHR_get_physical_device_properties2
// extension [6 of 17]: VK_KHR_get_surface_capabilities2
// extension [7 of 17]: VK_KHR_surface
// extension [8 of 17]: VK_EXT_debug_report
// extension [9 of 17]: VK_EXT_debug_utils
// extension [10 of 17]: VK_EXT_headless_surface
// extension [11 of 17]: VK_EXT_layer_settings
// extension [12 of 17]: VK_EXT_metal_surface
// extension [13 of 17]: VK_EXT_surface_maintenance1
// extension [14 of 17]: VK_EXT_swapchain_colorspace
// extension [15 of 17]: VK_MVK_macos_surface
// extension [16 of 17]: VK_KHR_portability_enumeration
// extension [17 of 17]: VK_LUNARG_direct_driver_loading
// 
// success: vulkan instance created.
// 
// available vulkan devices:
// device [1 of 1]: Apple M1 Pro
// type: integrated gpu
// api: 1.2.275
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
