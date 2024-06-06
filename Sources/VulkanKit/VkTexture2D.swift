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
  class Texture2D: Texture
  {
    func loadFromFile(atPath filename: String,
                      format: VkFormat,
                      device: Vulkan.Device,
                      copyQueue: VkQueue,
                      imageUsageFlags: VkImageUsageFlags = VK_IMAGE_USAGE_SAMPLED_BIT.rawValue,
                      imageLayout: VkImageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                      forceLinear: Bool = false)
    {
      var ktxTexture: UnsafeMutablePointer<ktxTexture>? = UnsafeMutablePointer<ktxTexture>.allocate(capacity: 1)
      let result: ktxResult = loadKTXFile(atPath: filename, target: &ktxTexture)
      assert(result == KTX_SUCCESS)

      guard let ktxTexture
      else { return }

      self.device = device
      width = ktxTexture.pointee.baseWidth
      height = ktxTexture.pointee.baseHeight
      mipLevels = ktxTexture.pointee.numLevels

      var ktxTextureData: UnsafeMutablePointer<ktx_uint8_t> = ktxTexture_GetData(ktxTexture)
      let ktxTextureSize = ktxTexture_GetDataSize(ktxTexture)

      // Get device properties for the requested texture format
      var formatProperties = VkFormatProperties()
      vkGetPhysicalDeviceFormatProperties(device.physicalDevice, format, &formatProperties)

      // Only use linear tiling if requested (and supported by the device)
      // Support for linear tiling is mostly limited, so prefer to use
      // optimal tiling instead
      // On most implementations linear tiling will only support a very
      // limited amount of formats and features (mip maps, cubemaps, arrays, etc.)
      let useStaging = !forceLinear
      var memAllocInfo: VkMemoryAllocateInfo = Vulkan.Initializers.memoryAllocateInfo()

      var memReqs = VkMemoryRequirements()

      // Use a separate command buffer for texture loading
      var copyCmd = UnsafePointer<VkCommandBuffer?>(device.createCommandBuffer(level: VK_COMMAND_BUFFER_LEVEL_PRIMARY, begin: true))

      if useStaging
      {
        // Create a host-visible staging buffer that contains the raw image data
        var stagingBuffer: VkBuffer? = nil
        var stagingMemory: VkDeviceMemory? = nil

        var bufferCreateInfo: VkBufferCreateInfo = Vulkan.Initializers.bufferCreateInfo()
        bufferCreateInfo.size = VkDeviceSize(ktxTextureSize)
        // This buffer is used as a transfer source for the buffer copy
        bufferCreateInfo.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT.rawValue
        bufferCreateInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE

        VK_CHECK_RESULT(vkCreateBuffer(device.logicalDevice, &bufferCreateInfo, nil, &stagingBuffer))

        // Get memory requirements for the staging buffer (alignment, memory type bits)
        vkGetBufferMemoryRequirements(device.logicalDevice, stagingBuffer, &memReqs)

        memAllocInfo.allocationSize = memReqs.size
        // Get memory type index for a host visible buffer
        memAllocInfo.memoryTypeIndex = device.getMemoryType(
          typeBits: &memReqs.memoryTypeBits,
          properties: VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT.rawValue | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT.rawValue
        )

        VK_CHECK_RESULT(vkAllocateMemory(device.logicalDevice, &memAllocInfo, nil, &stagingMemory))
        VK_CHECK_RESULT(vkBindBufferMemory(device.logicalDevice, stagingBuffer, stagingMemory, 0))

        // Copy texture data into staging buffer
        var data: UnsafeMutableRawPointer? = nil
        VK_CHECK_RESULT(vkMapMemory(device.logicalDevice, stagingMemory, 0, memReqs.size, 0, &data))
        guard let data
        else { return }

        memcpy(data, &ktxTextureData, ktxTextureSize)
        vkUnmapMemory(device.logicalDevice, stagingMemory)

        // Setup buffer copy regions for each mip level
        var bufferCopyRegions = VkBufferImageCopyVec()

        for i in 0 ..< mipLevels
        {
          let offset: ktx_size_t = 0
          // var result: ktx_error_code_e = ktxTexture_GetImageOffset(ktxTexture, i, 0, 0, &offset);
          // assert(result == KTX_SUCCESS);

          var bufferCopyRegion = VkBufferImageCopy()
          bufferCopyRegion.imageSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
          bufferCopyRegion.imageSubresource.mipLevel = i
          bufferCopyRegion.imageSubresource.baseArrayLayer = 0
          bufferCopyRegion.imageSubresource.layerCount = 1
          bufferCopyRegion.imageExtent.width = max(1, ktxTexture.pointee.baseWidth >> i)
          bufferCopyRegion.imageExtent.height = max(1, ktxTexture.pointee.baseHeight >> i)
          bufferCopyRegion.imageExtent.depth = 1
          bufferCopyRegion.bufferOffset = VkDeviceSize(offset)

          bufferCopyRegions.push_back(bufferCopyRegion)
        }

        // Create optimal tiled target image
        var imageCreateInfo: VkImageCreateInfo = Vulkan.Initializers.imageCreateInfo()
        imageCreateInfo.imageType = VK_IMAGE_TYPE_2D
        imageCreateInfo.format = format
        imageCreateInfo.mipLevels = mipLevels
        imageCreateInfo.arrayLayers = 1
        imageCreateInfo.samples = VK_SAMPLE_COUNT_1_BIT
        imageCreateInfo.tiling = VK_IMAGE_TILING_OPTIMAL
        imageCreateInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE
        imageCreateInfo.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED
        imageCreateInfo.extent = .init(width: width, height: height, depth: 1)
        imageCreateInfo.usage = imageUsageFlags
        // Ensure that the TRANSFER_DST bit is set for staging
        if (imageCreateInfo.usage & VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue) != 0
        {
          imageCreateInfo.usage |= VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue
        }
        VK_CHECK_RESULT(vkCreateImage(device.logicalDevice, &imageCreateInfo, nil, &image))

        vkGetImageMemoryRequirements(device.logicalDevice, image, &memReqs)

        memAllocInfo.allocationSize = memReqs.size

        memAllocInfo.memoryTypeIndex = device.getMemoryType(typeBits: &memReqs.memoryTypeBits, properties: VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT.rawValue)
        VK_CHECK_RESULT(vkAllocateMemory(device.logicalDevice, &memAllocInfo, nil, &deviceMemory))
        VK_CHECK_RESULT(vkBindImageMemory(device.logicalDevice, image, deviceMemory, 0))

        var subresourceRange = VkImageSubresourceRange()
        subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
        subresourceRange.baseMipLevel = 0
        subresourceRange.levelCount = mipLevels
        subresourceRange.layerCount = 1

        // Image barrier for optimal image (target)
        // Optimal image will be used as destination for the copy
        Vulkan.Tools.setImageLayout(
          cmdBuffer: copyCmd.pointee!,
          image: image!,
          oldImageLayout: VK_IMAGE_LAYOUT_UNDEFINED,
          newImageLayout: VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
          subresourceRange: subresourceRange
        )

        // Copy mip levels from staging buffer
        vkCmdCopyBufferToImage(
          copyCmd.pointee!,
          stagingBuffer,
          image,
          VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
          UInt32(bufferCopyRegions.size()),
          bufferCopyRegions.map { $0 }
        )

        // Change texture image layout to shader read after all mip levels have been copied
        self.imageLayout = imageLayout
        Vulkan.Tools.setImageLayout(
          cmdBuffer: copyCmd.pointee!,
          image: image!,
          oldImageLayout: VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
          newImageLayout: imageLayout,
          subresourceRange: subresourceRange
        )

        device.flushCommandBuffer(cmdBuffer: &copyCmd, queue: copyQueue)

        // Clean up staging resources
        vkDestroyBuffer(device.logicalDevice, stagingBuffer, nil)
        vkFreeMemory(device.logicalDevice, stagingMemory, nil)
      }
      else
      {
        // Prefer using optimal tiling, as linear tiling
        // may support only a small set of features
        // depending on implementation (e.g. no mip maps, only one layer, etc.)

        // Check if this support is supported for linear tiling
        assert((formatProperties.linearTilingFeatures & VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT.rawValue) != 0)

        var mappableImage: VkImage?
        var mappableMemory: VkDeviceMemory?

        var imageCreateInfo: VkImageCreateInfo = Vulkan.Initializers.imageCreateInfo()
        imageCreateInfo.imageType = VK_IMAGE_TYPE_2D
        imageCreateInfo.format = format
        imageCreateInfo.extent = .init(width: width, height: height, depth: 1)
        imageCreateInfo.mipLevels = 1
        imageCreateInfo.arrayLayers = 1
        imageCreateInfo.samples = VK_SAMPLE_COUNT_1_BIT
        imageCreateInfo.tiling = VK_IMAGE_TILING_LINEAR
        imageCreateInfo.usage = imageUsageFlags
        imageCreateInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE
        imageCreateInfo.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED

        // Load mip map level 0 to linear tiling image
        VK_CHECK_RESULT(vkCreateImage(device.logicalDevice, &imageCreateInfo, nil, &mappableImage))

        // Get memory requirements for this image
        // like size and alignment
        vkGetImageMemoryRequirements(device.logicalDevice, mappableImage, &memReqs)
        // Set memory allocation size to required memory size
        memAllocInfo.allocationSize = memReqs.size

        // Get memory type that can be mapped to host memory
        memAllocInfo.memoryTypeIndex = device.getMemoryType(
          typeBits: &memReqs.memoryTypeBits,
          properties: VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT.rawValue | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT.rawValue
        )

        // Allocate host memory
        VK_CHECK_RESULT(vkAllocateMemory(device.logicalDevice, &memAllocInfo, nil, &mappableMemory))

        // Bind allocated image for use
        VK_CHECK_RESULT(vkBindImageMemory(device.logicalDevice, mappableImage, mappableMemory, 0))

        // Get sub resource layout
        // Mip map count, array layer, etc.
        var subRes = VkImageSubresource()
        subRes.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
        subRes.mipLevel = 0

        var subResLayout = VkSubresourceLayout()
        var data: UnsafeMutableRawPointer?

        // Get sub resources layout
        // Includes row pitch, size offsets, etc.
        vkGetImageSubresourceLayout(device.logicalDevice, mappableImage, &subRes, &subResLayout)

        // Map image memory
        VK_CHECK_RESULT(vkMapMemory(device.logicalDevice, mappableMemory, 0, memReqs.size, 0, &data))

        // Copy image data into memory
        memcpy(data!, ktxTextureData, Int(memReqs.size))

        vkUnmapMemory(device.logicalDevice, mappableMemory)

        // Linear tiled images don't need to be staged
        // and can be directly used as textures
        image = mappableImage
        deviceMemory = mappableMemory
        self.imageLayout = imageLayout

        // Setup image memory barrier
        Vulkan.Tools.setImageLayout(
          cmdBuffer: copyCmd.pointee!,
          image: image!,
          aspectMask: VK_IMAGE_ASPECT_COLOR_BIT.rawValue,
          oldImageLayout: VK_IMAGE_LAYOUT_UNDEFINED,
          newImageLayout: imageLayout
        )

        device.flushCommandBuffer(cmdBuffer: &copyCmd, queue: copyQueue)
      }

      // ktxTexture_Destroy(ktxTexture)

      // Create a default sampler
      var samplerCreateInfo = VkSamplerCreateInfo()
      samplerCreateInfo.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
      samplerCreateInfo.magFilter = VK_FILTER_LINEAR
      samplerCreateInfo.minFilter = VK_FILTER_LINEAR
      samplerCreateInfo.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR
      samplerCreateInfo.addressModeU = VK_SAMPLER_ADDRESS_MODE_REPEAT
      samplerCreateInfo.addressModeV = VK_SAMPLER_ADDRESS_MODE_REPEAT
      samplerCreateInfo.addressModeW = VK_SAMPLER_ADDRESS_MODE_REPEAT
      samplerCreateInfo.mipLodBias = 0.0
      samplerCreateInfo.compareOp = VK_COMPARE_OP_NEVER
      samplerCreateInfo.minLod = 0.0
      // Max level-of-detail should match mip level count
      samplerCreateInfo.maxLod = useStaging ? Float(mipLevels) : 0.0
      // Only enable anisotropic filtering if enabled on the device
      samplerCreateInfo.maxAnisotropy = (device.enabledFeatures.samplerAnisotropy != 0) ? device.properties.limits.maxSamplerAnisotropy : 1.0
      samplerCreateInfo.anisotropyEnable = device.enabledFeatures.samplerAnisotropy
      samplerCreateInfo.borderColor = VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE
      VK_CHECK_RESULT(vkCreateSampler(device.logicalDevice, &samplerCreateInfo, nil, &sampler))

      // Create image view
      // Textures are not directly accessed by the shaders and
      // are abstracted by image views containing additional
      // information and sub resource ranges
      var viewCreateInfo = VkImageViewCreateInfo()
      viewCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
      viewCreateInfo.viewType = VK_IMAGE_VIEW_TYPE_2D
      viewCreateInfo.format = format
      viewCreateInfo.subresourceRange = .init(aspectMask: VK_IMAGE_ASPECT_COLOR_BIT.rawValue, baseMipLevel: 0, levelCount: 1, baseArrayLayer: 0, layerCount: 1)
      // Linear tiling usually won't support mip maps
      // Only set mip map count if optimal tiling is used
      viewCreateInfo.subresourceRange.levelCount = useStaging ? mipLevels : 1
      viewCreateInfo.image = image
      VK_CHECK_RESULT(vkCreateImageView(device.logicalDevice, &viewCreateInfo, nil, &imageView))

      // Update descriptor image info member that can be used for setting up descriptor sets
      updateDescriptor()
    }
  }
}
