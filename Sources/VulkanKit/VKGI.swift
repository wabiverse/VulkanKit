/* ----------------------------------------------------------------
 * :: :  V  U  L  K  A  N  :                                     ::
 * ----------------------------------------------------------------
 * This software is Licensed under the terms of the Apache License,
 * version 2.0 (the "Apache License") with the following additional
 * modification; you may not use this file except within compliance
 * of the Apache License and the following modification made to it.
 * Section 6. Trademarks. is deleted and replaced with:
 *
 * Trademarks. This License does not grant permission to use any of
 * its trade names, trademarks, service marks, or the product names
 * of this Licensor or its affiliates, except as required to comply
 * with Section 4(c.) of this License, and to reproduce the content
 * of the NOTICE file.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND without even an
 * implied warranty of MERCHANTABILITY, or FITNESS FOR A PARTICULAR
 * PURPOSE. See the Apache License for more details.
 *
 * You should have received a copy for this software license of the
 * Apache License along with this program; or, if not, please write
 * to the Free Software Foundation Inc., with the following address
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *         Copyright (C) 2024 Wabi Foundation. All Rights Reserved.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import Foundation
import vulkan

public extension Vulkan
{
  class GI
  {
    public var title = "Vulkan Graphics Interface"
    public var name = "vulkan.gi"

    public var prepared: Bool = false
    public var resized: Bool = false
    public var viewUpdated: Bool = false
    public var width: Int = 0
    public var height: Int = 0

    public var frameTimer: Float = 1.0

    public var vulkanDevice: Vulkan.Device?

    private var frameCounter: Int = 0
    private var lastFPS: Int = 0

    private var instance: VkInstance?
    private var supportedExtensions: [String] = []

    private var physicalDevice: VkPhysicalDevice?
    private var deviceProperties: VkPhysicalDeviceProperties = .init()
    private var deviceFeatures: VkPhysicalDeviceFeatures = .init()
    private var deviceMemoryProperties: VkPhysicalDeviceMemoryProperties = .init()
    private var enabledFeatures: VkPhysicalDeviceFeatures = .init()

    private var instanceExtensions: [String] = []
    private var enabledInstanceExtensions: [String] = []
    private var enabledDeviceExtensions: [String] = []

    // TODO: make these private
    public var device: VkDevice?
    public var queue: VkQueue?

    private var depthFormat: VkFormat = VK_FORMAT_UNDEFINED
    private var cmdPool: VkCommandPool?

    private var submitPipelineStages: VkPipelineStageFlags = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue
    private var submitInfo: VkSubmitInfo = .init()

    private var drawCmdBuffers: [VkCommandBuffer] = []
    private var renderPass: VkRenderPass?
    private var framebuffers: [VkFramebuffer] = []
    private var currentBuffer: Int = 0

    private var descriptorPool: VkDescriptorPool?
    private var shaderModules: [VkShaderModule] = []
    private var pipelineCache: VkPipelineCache?

    private var swapchain: VkSwapchainKHR?

    private struct Semaphores
    {
      var presentComplete: VkSemaphore?
      var renderComplete: VkSemaphore?
    }

    private var waitFences: [VkFence] = []

    private var requiresStencil: Bool = false

    public init()
    {}

    public func createInstance() -> VkResult
    {
      enabledInstanceExtensions.append(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)
      // enabledInstanceExtensions.append(VK_KHR_SURFACE_EXTENSION_NAME)
      #if os(macOS)
        /* macOS specific extensions. */
        enabledInstanceExtensions.append(VK_EXT_METAL_SURFACE_EXTENSION_NAME)
        enabledInstanceExtensions.append(VK_MVK_MACOS_SURFACE_EXTENSION_NAME)
      #endif /* os(macOS) */
      enabledInstanceExtensions.append(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)
      enabledInstanceExtensions.append(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME)

      // Get extensions supported by the instance and store for later use
      var extCount: UInt32 = 0
      vkEnumerateInstanceExtensionProperties(nil, &extCount, nil)
      if extCount > 0
      {
        let extensions = UnsafeMutablePointer<VkExtensionProperties>.allocate(capacity: Int(extCount))

        print("")
        print("available vulkan extensions:")
        if vkEnumerateInstanceExtensionProperties(nil, &extCount, &extensions.pointee) == VK_SUCCESS
        {
          for extIdx in 0 ..< extCount
          {
            let extName = withUnsafePointer(to: &extensions.advanced(by: Int(extIdx)).pointee.extensionName)
            {
              $0.withMemoryRebound(to: CChar.self, capacity: 256)
              {
                String(cString: $0)
              }
            }
            print("extension [\(extIdx + 1) of \(extCount)]: \(extName)")
            supportedExtensions.append(extName)
          }
        }
      }

      // Enabled requested instance extensions
      if !enabledInstanceExtensions.isEmpty
      {
        for enabledExtension in enabledInstanceExtensions
        {
          // output message if requested extension is not available.
          if !supportedExtensions.contains(enabledExtension)
          {
            fatalError("Enabled instance extension \(enabledExtension) is not present at instance level.")
          }
          instanceExtensions.append(enabledExtension)
        }
      }

      var appInfo = VkApplicationInfo()
      let appName = withUnsafePointer(to: &name)
      {
        $0.withMemoryRebound(to: CChar.self, capacity: 256)
        {
          $0
        }
      }
      appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
      appInfo.pApplicationName = appName
      appInfo.pEngineName = appName
      appInfo.apiVersion = vkApiVersion1_0()

      let extensions = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: instanceExtensions.count)
      for (idx, ext) in instanceExtensions.enumerated()
      {
        extensions.advanced(by: idx).pointee = ext.withCString { $0 }
      }
      #if DEBUG_VULKAN_EXTENSIONS
        for (idx, _) in instanceExtensions.enumerated()
        {
          print("got ext:", String(cString: extensions.advanced(by: idx).pointee!))
        }
      #endif // DEBUG_VULKAN_EXTENSIONS

      let result = createAppInfo(
        with: &appInfo,
        extensions: &extensions.pointee,
        extensionsCount: instanceExtensions.count
      )

      return result
    }

    @discardableResult
    public func initVulkan() -> Bool
    {
      // Create the instance
      var result = createInstance()
      if result != VK_SUCCESS
      {
        print("")
        Vulkan.Tools.errorString(result)
        return false
      }
      else
      {
        print("")
        print("success: vulkan instance created.")
      }

      // Physical device (number of available physical devices).
      var gpuCount: UInt32 = 0
      VK_CHECK_RESULT(vkEnumeratePhysicalDevices(instance, &gpuCount, nil))
      if gpuCount == 0
      {
        Vulkan.Tools.exitFatal("No device with Vulkan support found.")
        return false
      }

      // Enumerate devices.
      var physicalDevices = [VkPhysicalDevice?](repeating: VkPhysicalDevice(bitPattern: 0), count: Int(gpuCount))
      result = vkEnumeratePhysicalDevices(instance, &gpuCount, &physicalDevices)
      if result != VK_SUCCESS
      {
        Vulkan.Tools.exitFatal("Could not enumerate physical devices: \(result.rawValue).")
        return false
      }

      // GPU selection.
      let selectedDevice: UInt32 = 0
      print("")
      print("available vulkan devices:")
      for i in 0 ..< gpuCount
      {
        let deviceProperties = UnsafeMutablePointer<VkPhysicalDeviceProperties>.allocate(capacity: 1)
        vkGetPhysicalDeviceProperties(physicalDevices[Int(i)], deviceProperties)
        let deviceName = withUnsafePointer(to: &deviceProperties.pointee.deviceName)
        {
          $0.withMemoryRebound(to: CChar.self, capacity: 256)
          {
            String(cString: $0)
          }
        }
        print("device [\(i + 1) of \(gpuCount)]:", deviceName)
        switch deviceProperties.pointee.deviceType
        {
          case VK_PHYSICAL_DEVICE_TYPE_OTHER:
            print("type: other")
          case VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU:
            print("type: integrated gpu")
          case VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:
            print("type: discrete gpu")
          case VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:
            print("type: virtual gpu")
          case VK_PHYSICAL_DEVICE_TYPE_CPU:
            print("type: cpu")
          default:
            print("type: unknown")
        }

        let v = deviceProperties.pointee.apiVersion
        print("api:", Vulkan.Version.makeVersion(from: v))
      }

      guard let foundDevice = physicalDevices[Int(selectedDevice)]
      else
      {
        Vulkan.Tools.exitFatal("Could not find a device that supports Vulkan.")
        return false
      }

      physicalDevice = foundDevice

      return true
    }
  }
}

extension Vulkan.GI
{
  private func createAppInfo(
    with appInfo: UnsafePointer<VkApplicationInfo>,
    extensions: UnsafePointer<UnsafePointer<CChar>?>,
    extensionsCount: Int
  ) -> VkResult
  {
    var createApp = VkInstanceCreateInfo()

    createApp.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
    createApp.pApplicationInfo = appInfo
    createApp.flags = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR.rawValue

    createApp.enabledExtensionCount = UInt32(extensionsCount)
    createApp.ppEnabledExtensionNames = extensions

    return vkCreateInstance(&createApp, nil, &instance)
  }
}
