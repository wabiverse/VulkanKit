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
  class Device
  {
    public var physicalDevice: VkPhysicalDevice
    public var logicalDevice: VkDevice?

    public var properties: VkPhysicalDeviceProperties = .init()
    public var features: VkPhysicalDeviceFeatures = .init()
    public var enabledFeatures: VkPhysicalDeviceFeatures = .init()

    public var memoryProperties: VkPhysicalDeviceMemoryProperties = .init()
    public var queueFamilyProperties: [VkQueueFamilyProperties] = []
    public var supportedExtensions: [String] = []

    public var commandPool: VkCommandPool? = VkCommandPool(bitPattern: 0)

    public struct QueueFamilyIndices
    {
      public var graphics: UInt32 = 0
      public var compute: UInt32 = 0
      public var transfer: UInt32 = 0
    }

    public init(physicalDevice: VkPhysicalDevice)
    {
      assert(physicalDevice != VkPhysicalDevice(bitPattern: 0))
      self.physicalDevice = physicalDevice

      // Store Properties features, limits and properties of the physical device for later use
      // Device properties also contain limits and sparse properties
      vkGetPhysicalDeviceProperties(physicalDevice, &properties)
      // Features should be checked by the examples before using them
      vkGetPhysicalDeviceFeatures(physicalDevice, &features)
      // Memory properties are used regularly for creating all kinds of buffers
      vkGetPhysicalDeviceMemoryProperties(physicalDevice, &memoryProperties)

      // Queue family properties, used for setting up requested queues upon device creation
      var queueFamilyCount: UInt32 = 0
      vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, nil)
      assert(queueFamilyCount > 0)
      queueFamilyProperties = [VkQueueFamilyProperties](repeating: VkQueueFamilyProperties(), count: Int(queueFamilyCount))
      vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, &queueFamilyProperties)

      // Get list of supported extensions
      var extCount: UInt32 = 0
      vkEnumerateDeviceExtensionProperties(physicalDevice, nil, &extCount, nil)
      if extCount > 0
      {
        var extensions = [VkExtensionProperties](repeating: VkExtensionProperties(), count: Int(extCount))
        if vkEnumerateDeviceExtensionProperties(physicalDevice, nil, &extCount, &extensions) == VK_SUCCESS
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
    }

    deinit
    {
      if commandPool != nil
      {
        vkDestroyCommandPool(logicalDevice, commandPool!, nil)
      }

      if logicalDevice != nil
      {
        vkDestroyDevice(logicalDevice, nil)
      }
    }

    public func vkDevice() -> VkDevice
    {
      logicalDevice!
    }

    func createCommandBuffer(level: VkCommandBufferLevel, pool: VkCommandPool, begin: Bool) -> VkCommandBuffer
    {
      var cmdBufAllocateInfo = Vulkan.Initializers.commandBufferAllocateInfo(commandPool: pool, level: level, bufferCount: 1)
      var cmdBuffer = VkCommandBuffer(bitPattern: 0)
      VK_CHECK_RESULT(vkAllocateCommandBuffers(logicalDevice, &cmdBufAllocateInfo, &cmdBuffer))
      // If requested, also start recording for the new command buffer
      if begin
      {
        var cmdBufInfo: VkCommandBufferBeginInfo = Vulkan.Initializers.commandBufferBeginInfo()
        VK_CHECK_RESULT(vkBeginCommandBuffer(cmdBuffer, &cmdBufInfo))
      }
      return cmdBuffer!
    }

    func createCommandBuffer(level: VkCommandBufferLevel, begin: Bool) -> VkCommandBuffer
    {
      createCommandBuffer(level: level, pool: commandPool!, begin: begin)
    }

    func getMemoryType(typeBits: inout UInt32, properties: VkMemoryPropertyFlags, memTypeFound _: Bool? = nil) -> UInt32
    {
      // convert VkMemoryType tuple of memoryTypes to buffer pointer.
      let memoryTypes = withUnsafePointer(to: &memoryProperties.memoryTypes)
      {
        $0.withMemoryRebound(to: VkMemoryType.self, capacity: 32)
        {
          $0
        }
      }

      for i in 0 ..< memoryProperties.memoryTypeCount
      {
        if (typeBits & 1) == 1
        {
          if (memoryTypes[Int(i)].propertyFlags & properties) == properties
          {
            return i
          }
        }
        typeBits >>= 1
      }

      return 0
    }

    func flushCommandBuffer(cmdBuffer: inout UnsafePointer<VkCommandBuffer?>, queue: VkQueue, pool: VkCommandPool, free: Bool = true)
    {
      if cmdBuffer.pointee == nil
      {
        return
      }

      VK_CHECK_RESULT(vkEndCommandBuffer(cmdBuffer.pointee))

      var submitInfo = Vulkan.Initializers.submitInfo()
      submitInfo.commandBufferCount = 1
      submitInfo.pCommandBuffers = cmdBuffer
      // Create fence to ensure that the command buffer has finished executing
      var fenceInfo = Vulkan.Initializers.fenceCreateInfo(flags: 0)
      var fence: VkFence?
      VK_CHECK_RESULT(vkCreateFence(logicalDevice, &fenceInfo, nil, &fence))
      // Submit to the queue
      VK_CHECK_RESULT(vkQueueSubmit(queue, 1, &submitInfo, fence))
      // Wait for the fence to signal that command buffer has finished executing
      VK_CHECK_RESULT(vkWaitForFences(logicalDevice, 1, &fence, VK_TRUE, UInt64(DEFAULT_FENCE_TIMEOUT)))
      vkDestroyFence(logicalDevice, fence, nil)
      if free
      {
        vkFreeCommandBuffers(logicalDevice, pool, 1, cmdBuffer)
      }
    }

    func flushCommandBuffer(cmdBuffer: inout UnsafePointer<VkCommandBuffer?>, queue: VkQueue, free: Bool = true)
    {
      flushCommandBuffer(cmdBuffer: &cmdBuffer, queue: queue, pool: commandPool!, free: free)
    }
  }
}
