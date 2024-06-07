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
  class Base
  {
    public var title = "Vulkan Base"
    public var name = "vulkan.base"

    public var prepared: Bool = false
    public var resized: Bool = false
    public var viewUpdated: Bool = false
    public var width: Int = 0
    public var height: Int = 0

    public var frameTimer: Float = 1.0

    public var vulkanDevice: Vulkan.Device = .init()

    private var frameCounter: Int = 0
    private var lastFPS: Int = 0

    private var instance: VkInstance? = .init(bitPattern: 0)!
    private var supportedExtensions: [String] = []

    private var physicalDevice: VkPhysicalDevice = .init(bitPattern: 0)!
    private var deviceProperties: VkPhysicalDeviceProperties = .init()
    private var deviceFeatures: VkPhysicalDeviceFeatures = .init()
    private var deviceMemoryProperties: VkPhysicalDeviceMemoryProperties = .init()
    private var enabledFeatures: VkPhysicalDeviceFeatures = .init()

    private var enabledDeviceExtensions: [String] = []
    private var enabledInstanceExtensions: [String] = []

    // TODO: make these private
    public var device: VkDevice = .init(bitPattern: 0)!
    public var queue: VkQueue = .init(bitPattern: 0)!

    private var depthFormat: VkFormat = VK_FORMAT_UNDEFINED
    private var cmdPool: VkCommandPool = .init(bitPattern: 0)!

    private var submitPipelineStages: VkPipelineStageFlags = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue
    private var submitInfo: VkSubmitInfo = .init()

    private var drawCmdBuffers: [VkCommandBuffer] = []
    private var renderPass: VkRenderPass = .init(bitPattern: 0)!
    private var framebuffers: [VkFramebuffer] = []
    private var currentBuffer: Int = 0

    private var descriptorPool: VkDescriptorPool = .init(bitPattern: 0)!
    private var shaderModules: [VkShaderModule] = []
    private var pipelineCache: VkPipelineCache = .init(bitPattern: 0)!

    private var swapchain: VkSwapchainKHR = .init(bitPattern: 0)!

    private struct Semaphores
    {
      var presentComplete: VkSemaphore = .init(bitPattern: 0)!
      var renderComplete: VkSemaphore = .init(bitPattern: 0)!
    }

    private var waitFences: [VkFence] = []

    private var requiresStencil: Bool = false

    public init()
    {}

    public func createInstance() -> VkResult
    {
      var instanceExtensions: [String] = [VK_KHR_SURFACE_EXTENSION_NAME]

      // Get extensions supported by the instance and store for later use
      var extCount: UInt32 = 0
      vkEnumerateInstanceExtensionProperties(nil, &extCount, nil)
      if extCount > 0
      {
        let extensions = [VkExtensionProperties](repeating: VkExtensionProperties(), count: Int(extCount))
        var firstExt = extensions.first!
        if vkEnumerateInstanceExtensionProperties(nil, &extCount, &firstExt) == VK_SUCCESS
        {
          for ext in extensions
          {
            // convert cchar tuple of extension name to string.
            var extensionName = ext.extensionName
            let extName = withUnsafePointer(to: &extensionName)
            {
              $0.withMemoryRebound(to: CChar.self, capacity: 256)
              {
                String(cString: $0)
              }
            }

            // Add extension to list of supported extensions.
            supportedExtensions.append(extName)
          }
        }
      }

      // Enabled requested instance extensions
      if !enabledInstanceExtensions.isEmpty
      {
        for enabledExtension in enabledInstanceExtensions
        {
          // Output message if requested extension is not available
          if supportedExtensions.contains(enabledExtension)
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
      appInfo.apiVersion = Vulkan.shared.fullVersion

      var createApp = VkInstanceCreateInfo()
      var appInfoPtr = withUnsafePointer(to: &appInfo)
      {
        $0.withMemoryRebound(to: VkApplicationInfo.self, capacity: 1)
        {
          $0
        }
      }
      let result = createAppInfo(
        for: &createApp,
        with: &appInfoPtr,
        extensions: &instanceExtensions
      )

      return result
    }

    public func initVulkan() -> Bool
    {
      // Create the instance
      var result = createInstance()
      if result != VK_SUCCESS
      {
        Vulkan.Tools.exitFatal("Could not create Vulkan instance: \(result.rawValue).")
        return false
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
      print("available vulkan devices:")
      for i in 0 ..< gpuCount
      {
        var deviceProperties: VkPhysicalDeviceProperties = .init()
        vkGetPhysicalDeviceProperties(physicalDevices[Int(i)], &deviceProperties)
        print("device [\(i)]:", deviceProperties.deviceName)
        print("type:", deviceProperties.deviceType)
        print("api:", deviceProperties.apiVersion)
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

extension Vulkan.Base
{
  private func createAppInfo(
    for createInfoInstance: inout VkInstanceCreateInfo,
    with appInfo: inout UnsafePointer<VkApplicationInfo>,
    extensions: inout [String]
  ) -> VkResult
  {
    createInfoInstance.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
    createInfoInstance.pApplicationInfo = appInfo

    if !extensions.isEmpty
    {
      createInfoInstance.enabledExtensionCount = UInt32(extensions.count)
      var enabledExts = extensions
      let extensionsPtr = withUnsafePointer(to: &enabledExts)
      {
        $0.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: extensions.count)
        {
          $0
        }
      }
      createInfoInstance.ppEnabledExtensionNames = extensionsPtr
    }

    return vkCreateInstance(&createInfoInstance, nil, &instance)
  }
}
