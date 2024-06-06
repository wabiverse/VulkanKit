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

func VK_CHECK_RESULT(_ f: VkResult)
{
  let res = VkResult(f.rawValue)
  if res != VK_SUCCESS
  {
    Vulkan.Tools.errorString(res)
    assert(res == VK_SUCCESS)
  }
}

public extension Vulkan
{
  enum Tools
  {
    static func fileExists(atPath filename: String) -> Bool
    {
      FileManager.default.fileExists(atPath: filename, isDirectory: nil)
    }

    static func errorString(_ result: @autoclosure () -> VkResult = VkResult(0),
                            file: StaticString = #file,
                            line: UInt = #line)
    {
      fatalError("Fatal: VkResult is \(result()) in \(file) at line \(line)")
    }

    static func exitFatal(_ message: @autoclosure () -> String = String(),
                          file: StaticString = #file,
                          line: UInt = #line)
    {
      fatalError(message(), file: file, line: line)
    }

    static func setImageLayout(
      cmdBuffer: VkCommandBuffer,
      image: VkImage,
      oldImageLayout: VkImageLayout,
      newImageLayout: VkImageLayout,
      subresourceRange: VkImageSubresourceRange,
      srcStageMask: VkPipelineStageFlags = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT.rawValue,
      dstStageMask: VkPipelineStageFlags = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT.rawValue
    )
    {
      // Create an image barrier object
      var imageMemoryBarrier: VkImageMemoryBarrier = Vulkan.Initializers.imageMemoryBarrier()
      imageMemoryBarrier.oldLayout = oldImageLayout
      imageMemoryBarrier.newLayout = newImageLayout
      imageMemoryBarrier.image = image
      imageMemoryBarrier.subresourceRange = subresourceRange

      // Source layouts (old)
      // Source access mask controls actions that have to be finished on the old layout
      // before it will be transitioned to the new layout
      switch oldImageLayout
      {
        case VK_IMAGE_LAYOUT_UNDEFINED:
          // Image layout is undefined (or does not matter)
          // Only valid as initial layout
          // No flags required, listed only for completeness
          imageMemoryBarrier.srcAccessMask = 0

        case VK_IMAGE_LAYOUT_PREINITIALIZED:
          // Image is preinitialized
          // Only valid as initial layout for linear images, preserves memory contents
          // Make sure host writes have been finished
          imageMemoryBarrier.srcAccessMask = VK_ACCESS_HOST_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
          // Image is a color attachment
          // Make sure any writes to the color buffer have been finished
          imageMemoryBarrier.srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
          // Image is a depth/stencil attachment
          // Make sure any writes to the depth/stencil buffer have been finished
          imageMemoryBarrier.srcAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
          // Image is a transfer source
          // Make sure any reads from the image have been finished
          imageMemoryBarrier.srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue

        case VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
          // Image is a transfer destination
          // Make sure any writes to the image have been finished
          imageMemoryBarrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
          // Image is read by a shader
          // Make sure any shader reads from the image have been finished
          imageMemoryBarrier.srcAccessMask = VK_ACCESS_SHADER_READ_BIT.rawValue
        default:
          // Other source layouts aren't handled (yet)
          break
      }

      // Target layouts (new)
      // Destination access mask controls the dependency for the new image layout
      switch newImageLayout
      {
        case VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
          // Image will be used as a transfer destination
          // Make sure any writes to the image have been finished
          imageMemoryBarrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
          // Image will be used as a transfer source
          // Make sure any reads from the image have been finished
          imageMemoryBarrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue

        case VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
          // Image will be used as a color attachment
          // Make sure any writes to the color buffer have been finished
          imageMemoryBarrier.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
          // Image layout will be used as a depth/stencil attachment
          // Make sure any writes to depth/stencil buffer have been finished
          imageMemoryBarrier.dstAccessMask = imageMemoryBarrier.dstAccessMask | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT.rawValue

        case VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
          // Image will be read in a shader (sampler, input attachment)
          // Make sure any writes to the image have been finished
          if imageMemoryBarrier.srcAccessMask == 0
          {
            imageMemoryBarrier.srcAccessMask = VK_ACCESS_HOST_WRITE_BIT.rawValue | VK_ACCESS_TRANSFER_WRITE_BIT.rawValue
          }
          imageMemoryBarrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT.rawValue
        default:
          // Other source layouts aren't handled (yet)
          break
      }

      // Put barrier inside setup command buffer
      vkCmdPipelineBarrier(
        cmdBuffer,
        srcStageMask,
        dstStageMask,
        0,
        0, nil,
        0, nil,
        1, &imageMemoryBarrier
      )
    }

    static func setImageLayout(
      cmdBuffer: VkCommandBuffer,
      image: VkImage,
      aspectMask: VkImageAspectFlags,
      oldImageLayout: VkImageLayout,
      newImageLayout: VkImageLayout,
      srcStageMask: VkPipelineStageFlags = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT.rawValue,
      dstStageMask: VkPipelineStageFlags = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT.rawValue
    )
    {
      var subresourceRange = VkImageSubresourceRange()
      subresourceRange.aspectMask = aspectMask
      subresourceRange.baseMipLevel = 0
      subresourceRange.levelCount = 1
      subresourceRange.layerCount = 1

      setImageLayout(
        cmdBuffer: cmdBuffer,
        image: image,
        oldImageLayout: oldImageLayout,
        newImageLayout: newImageLayout,
        subresourceRange: subresourceRange,
        srcStageMask: srcStageMask,
        dstStageMask: dstStageMask
      )
    }
  }
}
