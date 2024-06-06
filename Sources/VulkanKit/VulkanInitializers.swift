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
  enum Initializers
  {
    @inline(__always)
    static func memoryAllocateInfo() -> VkMemoryAllocateInfo
    {
      var memAllocInfo = VkMemoryAllocateInfo()
      memAllocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
      return memAllocInfo
    }

    @inline(__always)
    static func mappedMemoryRange() -> VkMappedMemoryRange
    {
      var mappedMemoryRange = VkMappedMemoryRange()
      mappedMemoryRange.sType = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE
      return mappedMemoryRange
    }

    @inline(__always)
    static func commandBufferAllocateInfo(
      commandPool: VkCommandPool,
      level: VkCommandBufferLevel,
      bufferCount: UInt32
    ) -> VkCommandBufferAllocateInfo
    {
      var commandBufferAllocateInfo = VkCommandBufferAllocateInfo()
      commandBufferAllocateInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
      commandBufferAllocateInfo.commandPool = commandPool
      commandBufferAllocateInfo.level = level
      commandBufferAllocateInfo.commandBufferCount = bufferCount
      return commandBufferAllocateInfo
    }

    @inline(__always)
    static func commandPoolCreateInfo() -> VkCommandPoolCreateInfo
    {
      var cmdPoolCreateInfo = VkCommandPoolCreateInfo()
      cmdPoolCreateInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
      return cmdPoolCreateInfo
    }

    @inline(__always)
    static func commandBufferBeginInfo() -> VkCommandBufferBeginInfo
    {
      var cmdBufferBeginInfo = VkCommandBufferBeginInfo()
      cmdBufferBeginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
      return cmdBufferBeginInfo
    }

    @inline(__always)
    static func commandBufferInheritanceInfo() -> VkCommandBufferInheritanceInfo
    {
      var cmdBufferInheritanceInfo = VkCommandBufferInheritanceInfo()
      cmdBufferInheritanceInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO
      return cmdBufferInheritanceInfo
    }

    @inline(__always)
    static func renderPassBeginInfo() -> VkRenderPassBeginInfo
    {
      var renderPassBeginInfo = VkRenderPassBeginInfo()
      renderPassBeginInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
      return renderPassBeginInfo
    }

    @inline(__always)
    static func renderPassCreateInfo() -> VkRenderPassCreateInfo
    {
      var renderPassCreateInfo = VkRenderPassCreateInfo()
      renderPassCreateInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
      return renderPassCreateInfo
    }

    /** @brief Initialize an image memory barrier with no image transfer ownership */
    @inline(__always)
    static func imageMemoryBarrier() -> VkImageMemoryBarrier
    {
      var imageMemoryBarrier = VkImageMemoryBarrier()
      imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER
      imageMemoryBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED
      imageMemoryBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED
      return imageMemoryBarrier
    }

    /** @brief Initialize a buffer memory barrier with no image transfer ownership */
    @inline(__always)
    static func bufferMemoryBarrier() -> VkBufferMemoryBarrier
    {
      var bufferMemoryBarrier = VkBufferMemoryBarrier()
      bufferMemoryBarrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER
      bufferMemoryBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED
      bufferMemoryBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED
      return bufferMemoryBarrier
    }

    @inline(__always)
    static func memoryBarrier() -> VkMemoryBarrier
    {
      var memoryBarrier = VkMemoryBarrier()
      memoryBarrier.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER
      return memoryBarrier
    }

    @inline(__always)
    static func imageCreateInfo() -> VkImageCreateInfo
    {
      var imageCreateInfo = VkImageCreateInfo()
      imageCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO
      return imageCreateInfo
    }

    @inline(__always)
    static func samplerCreateInfo() -> VkSamplerCreateInfo
    {
      var samplerCreateInfo = VkSamplerCreateInfo()
      samplerCreateInfo.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
      samplerCreateInfo.maxAnisotropy = 1.0
      return samplerCreateInfo
    }

    @inline(__always)
    static func imageViewCreateInfo() -> VkImageViewCreateInfo
    {
      var imageViewCreateInfo = VkImageViewCreateInfo()
      imageViewCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
      return imageViewCreateInfo
    }

    @inline(__always)
    static func framebufferCreateInfo() -> VkFramebufferCreateInfo
    {
      var framebufferCreateInfo = VkFramebufferCreateInfo()
      framebufferCreateInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
      return framebufferCreateInfo
    }

    @inline(__always)
    static func semaphoreCreateInfo() -> VkSemaphoreCreateInfo
    {
      var semaphoreCreateInfo = VkSemaphoreCreateInfo()
      semaphoreCreateInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
      return semaphoreCreateInfo
    }

    @inline(__always)
    static func fenceCreateInfo(flags: VkFenceCreateFlags = 0) -> VkFenceCreateInfo
    {
      var fenceCreateInfo = VkFenceCreateInfo()
      fenceCreateInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
      fenceCreateInfo.flags = flags
      return fenceCreateInfo
    }

    @inline(__always)
    static func eventCreateInfo() -> VkEventCreateInfo
    {
      var eventCreateInfo = VkEventCreateInfo()
      eventCreateInfo.sType = VK_STRUCTURE_TYPE_EVENT_CREATE_INFO
      return eventCreateInfo
    }

    @inline(__always)
    static func submitInfo() -> VkSubmitInfo
    {
      var submitInfo = VkSubmitInfo()
      submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
      return submitInfo
    }

    @inline(__always)
    static func viewport(
      width: Float,
      height: Float,
      minDepth: Float,
      maxDepth: Float
    ) -> VkViewport
    {
      var viewport = VkViewport()
      viewport.width = width
      viewport.height = height
      viewport.minDepth = minDepth
      viewport.maxDepth = maxDepth
      return viewport
    }

    @inline(__always)
    static func rect2D(
      width: UInt32,
      height: UInt32,
      offsetX: Int32,
      offsetY: Int32
    ) -> VkRect2D
    {
      var rect2D = VkRect2D()
      rect2D.extent.width = width
      rect2D.extent.height = height
      rect2D.offset.x = offsetX
      rect2D.offset.y = offsetY
      return rect2D
    }

    @inline(__always)
    static func bufferCreateInfo() -> VkBufferCreateInfo
    {
      var bufCreateInfo = VkBufferCreateInfo()
      bufCreateInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
      return bufCreateInfo
    }

    @inline(__always)
    static func bufferCreateInfo(
      usage: VkBufferUsageFlags,
      size: VkDeviceSize
    ) -> VkBufferCreateInfo
    {
      var bufCreateInfo = VkBufferCreateInfo()
      bufCreateInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
      bufCreateInfo.usage = usage
      bufCreateInfo.size = size
      return bufCreateInfo
    }

    @inline(__always)
    static func descriptorPoolCreateInfo(
      poolSizeCount: UInt32,
      pPoolSizes: UnsafePointer<VkDescriptorPoolSize>,
      maxSets: UInt32
    ) -> VkDescriptorPoolCreateInfo
    {
      var descriptorPoolInfo = VkDescriptorPoolCreateInfo()
      descriptorPoolInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO
      descriptorPoolInfo.poolSizeCount = poolSizeCount
      descriptorPoolInfo.pPoolSizes = pPoolSizes
      descriptorPoolInfo.maxSets = maxSets
      return descriptorPoolInfo
    }

    @inline(__always)
    static func descriptorPoolCreateInfo(
      poolSizes: VkDescriptorPoolSizeVec,
      maxSets: UInt32
    ) -> VkDescriptorPoolCreateInfo
    {
      var descriptorPoolInfo = VkDescriptorPoolCreateInfo()
      descriptorPoolInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO
      descriptorPoolInfo.poolSizeCount = UInt32(poolSizes.size())
      descriptorPoolInfo.pPoolSizes = UnsafePointer<VkDescriptorPoolSize>(Array<VkDescriptorPoolSize>(poolSizes).withUnsafeBufferPointer { $0.baseAddress })
      descriptorPoolInfo.maxSets = maxSets
      return descriptorPoolInfo
    }

    @inline(__always)
    static func descriptorPoolSize(
      type: VkDescriptorType,
      descriptorCount: UInt32
    ) -> VkDescriptorPoolSize
    {
      var descriptorPoolSize = VkDescriptorPoolSize()
      descriptorPoolSize.type = type
      descriptorPoolSize.descriptorCount = descriptorCount
      return descriptorPoolSize
    }

    @inline(__always)
    static func descriptorSetLayoutBinding(
      type: VkDescriptorType,
      stageFlags: VkShaderStageFlags,
      binding: UInt32,
      descriptorCount: UInt32 = 1
    ) -> VkDescriptorSetLayoutBinding
    {
      var setLayoutBinding = VkDescriptorSetLayoutBinding()
      setLayoutBinding.descriptorType = type
      setLayoutBinding.stageFlags = stageFlags
      setLayoutBinding.binding = binding
      setLayoutBinding.descriptorCount = descriptorCount
      return setLayoutBinding
    }

    @inline(__always)
    static func descriptorSetLayoutCreateInfo(
      pBindings: UnsafePointer<VkDescriptorSetLayoutBinding>,
      bindingCount: UInt32
    ) -> VkDescriptorSetLayoutCreateInfo
    {
      var descriptorSetLayoutCreateInfo = VkDescriptorSetLayoutCreateInfo()
      descriptorSetLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO
      descriptorSetLayoutCreateInfo.pBindings = pBindings
      descriptorSetLayoutCreateInfo.bindingCount = bindingCount
      return descriptorSetLayoutCreateInfo
    }

    @inline(__always)
    static func descriptorSetLayoutCreateInfo(
      bindings: VkDescriptorSetLayoutBindingVec) -> VkDescriptorSetLayoutCreateInfo
    {
      var descriptorSetLayoutCreateInfo = VkDescriptorSetLayoutCreateInfo()
      descriptorSetLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO
      descriptorSetLayoutCreateInfo.pBindings = UnsafePointer<VkDescriptorSetLayoutBinding>(Array<VkDescriptorSetLayoutBinding>(bindings).withUnsafeBufferPointer { $0.baseAddress })
      descriptorSetLayoutCreateInfo.bindingCount = UInt32(bindings.size())
      return descriptorSetLayoutCreateInfo
    }

    @inline(__always)
    static func pipelineLayoutCreateInfo(
      pSetLayouts: UnsafePointer<VkDescriptorSetLayout?>,
      setLayoutCount: UInt32 = 1
    ) -> VkPipelineLayoutCreateInfo
    {
      var pipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo()
      pipelineLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
      pipelineLayoutCreateInfo.setLayoutCount = setLayoutCount
      pipelineLayoutCreateInfo.pSetLayouts = pSetLayouts
      return pipelineLayoutCreateInfo
    }

    @inline(__always)
    static func pipelineLayoutCreateInfo(
      setLayoutCount: UInt32 = 1) -> VkPipelineLayoutCreateInfo
    {
      var pipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo()
      pipelineLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
      pipelineLayoutCreateInfo.setLayoutCount = setLayoutCount
      return pipelineLayoutCreateInfo
    }

    @inline(__always)
    static func descriptorSetAllocateInfo(
      descriptorPool: VkDescriptorPool,
      pSetLayouts: UnsafePointer<VkDescriptorSetLayout?>,
      descriptorSetCount: UInt32
    ) -> VkDescriptorSetAllocateInfo
    {
      var descriptorSetAllocateInfo = VkDescriptorSetAllocateInfo()
      descriptorSetAllocateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO
      descriptorSetAllocateInfo.descriptorPool = descriptorPool
      descriptorSetAllocateInfo.pSetLayouts = pSetLayouts
      descriptorSetAllocateInfo.descriptorSetCount = descriptorSetCount
      return descriptorSetAllocateInfo
    }

    @inline(__always)
    static func descriptorImageInfo(sampler: VkSampler, imageView: VkImageView, imageLayout: VkImageLayout) -> VkDescriptorImageInfo
    {
      var descriptorImageInfo = VkDescriptorImageInfo()
      descriptorImageInfo.sampler = sampler
      descriptorImageInfo.imageView = imageView
      descriptorImageInfo.imageLayout = imageLayout
      return descriptorImageInfo
    }

    @inline(__always)
    static func writeDescriptorSet(
      dstSet: VkDescriptorSet,
      type: VkDescriptorType,
      binding: UInt32,
      bufferInfo: UnsafePointer<VkDescriptorBufferInfo>,
      descriptorCount: UInt32 = 1
    ) -> VkWriteDescriptorSet
    {
      var writeDescriptorSet = VkWriteDescriptorSet()
      writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET
      writeDescriptorSet.dstSet = dstSet
      writeDescriptorSet.descriptorType = type
      writeDescriptorSet.dstBinding = binding
      writeDescriptorSet.pBufferInfo = bufferInfo
      writeDescriptorSet.descriptorCount = descriptorCount
      return writeDescriptorSet
    }

    @inline(__always)
    static func writeDescriptorSet(
      dstSet: VkDescriptorSet,
      type: VkDescriptorType,
      binding: UInt32,
      imageInfo: UnsafePointer<VkDescriptorImageInfo>,
      descriptorCount: UInt32 = 1
    ) -> VkWriteDescriptorSet
    {
      var writeDescriptorSet = VkWriteDescriptorSet()
      writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET
      writeDescriptorSet.dstSet = dstSet
      writeDescriptorSet.descriptorType = type
      writeDescriptorSet.dstBinding = binding
      writeDescriptorSet.pImageInfo = imageInfo
      writeDescriptorSet.descriptorCount = descriptorCount
      return writeDescriptorSet
    }

    @inline(__always)
    static func vertexInputBindingDescription(
      binding: UInt32,
      stride: UInt32,
      inputRate: VkVertexInputRate
    ) -> VkVertexInputBindingDescription
    {
      var vInputBindDescription = VkVertexInputBindingDescription()
      vInputBindDescription.binding = binding
      vInputBindDescription.stride = stride
      vInputBindDescription.inputRate = inputRate
      return vInputBindDescription
    }

    @inline(__always)
    static func vertexInputAttributeDescription(
      binding: UInt32,
      location: UInt32,
      format: VkFormat,
      offset: UInt32
    ) -> VkVertexInputAttributeDescription
    {
      var vInputAttribDescription = VkVertexInputAttributeDescription()
      vInputAttribDescription.location = location
      vInputAttribDescription.binding = binding
      vInputAttribDescription.format = format
      vInputAttribDescription.offset = offset
      return vInputAttribDescription
    }

    @inline(__always)
    static func pipelineVertexInputStateCreateInfo() -> VkPipelineVertexInputStateCreateInfo
    {
      var pipelineVertexInputStateCreateInfo = VkPipelineVertexInputStateCreateInfo()
      pipelineVertexInputStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
      return pipelineVertexInputStateCreateInfo
    }

    @inline(__always)
    static func pipelineVertexInputStateCreateInfo(
      vertexBindingDescriptions: VkVertexInputBindingDescriptionVec,
      vertexAttributeDescriptions: VkVertexInputAttributeDescriptionVec
    ) -> VkPipelineVertexInputStateCreateInfo
    {
      var pipelineVertexInputStateCreateInfo = VkPipelineVertexInputStateCreateInfo()
      pipelineVertexInputStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
      pipelineVertexInputStateCreateInfo.vertexBindingDescriptionCount = UInt32(vertexBindingDescriptions.size())
      pipelineVertexInputStateCreateInfo.pVertexBindingDescriptions = UnsafePointer<VkVertexInputBindingDescription>(Array<VkVertexInputBindingDescription>(vertexBindingDescriptions).withUnsafeBufferPointer { $0.baseAddress })
      pipelineVertexInputStateCreateInfo.vertexAttributeDescriptionCount = UInt32(vertexAttributeDescriptions.size())
      pipelineVertexInputStateCreateInfo.pVertexAttributeDescriptions = UnsafePointer<VkVertexInputAttributeDescription>(Array<VkVertexInputAttributeDescription>(vertexAttributeDescriptions).withUnsafeBufferPointer { $0.baseAddress })
      return pipelineVertexInputStateCreateInfo
    }

    @inline(__always)
    static func pipelineInputAssemblyStateCreateInfo(
      topology: VkPrimitiveTopology,
      flags: VkPipelineInputAssemblyStateCreateFlags,
      primitiveRestartEnable: VkBool32
    ) -> VkPipelineInputAssemblyStateCreateInfo
    {
      var pipelineInputAssemblyStateCreateInfo = VkPipelineInputAssemblyStateCreateInfo()
      pipelineInputAssemblyStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
      pipelineInputAssemblyStateCreateInfo.topology = topology
      pipelineInputAssemblyStateCreateInfo.flags = flags
      pipelineInputAssemblyStateCreateInfo.primitiveRestartEnable = primitiveRestartEnable
      return pipelineInputAssemblyStateCreateInfo
    }

    @inline(__always)
    static func pipelineRasterizationStateCreateInfo(
      polygonMode: VkPolygonMode,
      cullMode: VkCullModeFlags,
      frontFace: VkFrontFace,
      flags: VkPipelineRasterizationStateCreateFlags = 0
    ) -> VkPipelineRasterizationStateCreateInfo
    {
      var pipelineRasterizationStateCreateInfo = VkPipelineRasterizationStateCreateInfo()
      pipelineRasterizationStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
      pipelineRasterizationStateCreateInfo.polygonMode = polygonMode
      pipelineRasterizationStateCreateInfo.cullMode = cullMode
      pipelineRasterizationStateCreateInfo.frontFace = frontFace
      pipelineRasterizationStateCreateInfo.flags = flags
      pipelineRasterizationStateCreateInfo.depthClampEnable = VK_FALSE
      pipelineRasterizationStateCreateInfo.lineWidth = 1.0
      return pipelineRasterizationStateCreateInfo
    }

    @inline(__always)
    static func pipelineColorBlendAttachmentState(
      colorWriteMask: VkColorComponentFlags,
      blendEnable: VkBool32
    ) -> VkPipelineColorBlendAttachmentState
    {
      var pipelineColorBlendAttachmentState = VkPipelineColorBlendAttachmentState()
      pipelineColorBlendAttachmentState.colorWriteMask = colorWriteMask
      pipelineColorBlendAttachmentState.blendEnable = blendEnable
      return pipelineColorBlendAttachmentState
    }

    @inline(__always)
    static func pipelineColorBlendStateCreateInfo(
      attachmentCount: UInt32,
      pAttachments: UnsafePointer<VkPipelineColorBlendAttachmentState>
    ) -> VkPipelineColorBlendStateCreateInfo
    {
      var pipelineColorBlendStateCreateInfo = VkPipelineColorBlendStateCreateInfo()
      pipelineColorBlendStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
      pipelineColorBlendStateCreateInfo.attachmentCount = attachmentCount
      pipelineColorBlendStateCreateInfo.pAttachments = pAttachments
      return pipelineColorBlendStateCreateInfo
    }

    @inline(__always)
    static func pipelineDepthStencilStateCreateInfo(
      depthTestEnable: VkBool32,
      depthWriteEnable: VkBool32,
      depthCompareOp: VkCompareOp
    ) -> VkPipelineDepthStencilStateCreateInfo
    {
      var pipelineDepthStencilStateCreateInfo = VkPipelineDepthStencilStateCreateInfo()
      pipelineDepthStencilStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO
      pipelineDepthStencilStateCreateInfo.depthTestEnable = depthTestEnable
      pipelineDepthStencilStateCreateInfo.depthWriteEnable = depthWriteEnable
      pipelineDepthStencilStateCreateInfo.depthCompareOp = depthCompareOp
      pipelineDepthStencilStateCreateInfo.back.compareOp = VK_COMPARE_OP_ALWAYS
      return pipelineDepthStencilStateCreateInfo
    }

    @inline(__always)
    static func pipelineViewportStateCreateInfo(
      viewportCount: UInt32,
      scissorCount: UInt32,
      flags: VkPipelineViewportStateCreateFlags = 0
    ) -> VkPipelineViewportStateCreateInfo
    {
      var pipelineViewportStateCreateInfo = VkPipelineViewportStateCreateInfo()
      pipelineViewportStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
      pipelineViewportStateCreateInfo.viewportCount = viewportCount
      pipelineViewportStateCreateInfo.scissorCount = scissorCount
      pipelineViewportStateCreateInfo.flags = flags
      return pipelineViewportStateCreateInfo
    }

    @inline(__always)
    static func pipelineMultisampleStateCreateInfo(
      rasterizationSamples: VkSampleCountFlagBits,
      flags: VkPipelineMultisampleStateCreateFlags = 0
    ) -> VkPipelineMultisampleStateCreateInfo
    {
      var pipelineMultisampleStateCreateInfo = VkPipelineMultisampleStateCreateInfo()
      pipelineMultisampleStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
      pipelineMultisampleStateCreateInfo.rasterizationSamples = rasterizationSamples
      pipelineMultisampleStateCreateInfo.flags = flags
      return pipelineMultisampleStateCreateInfo
    }

    @inline(__always)
    static func pipelineDynamicStateCreateInfo(
      pDynamicStates: UnsafePointer<VkDynamicState>,
      dynamicStateCount: UInt32,
      flags: VkPipelineDynamicStateCreateFlags = 0
    ) -> VkPipelineDynamicStateCreateInfo
    {
      var pipelineDynamicStateCreateInfo = VkPipelineDynamicStateCreateInfo()
      pipelineDynamicStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
      pipelineDynamicStateCreateInfo.pDynamicStates = pDynamicStates
      pipelineDynamicStateCreateInfo.dynamicStateCount = dynamicStateCount
      pipelineDynamicStateCreateInfo.flags = flags
      return pipelineDynamicStateCreateInfo
    }

    @inline(__always)
    static func pipelineDynamicStateCreateInfo(
      pDynamicStates: VkDynamicStateVec,
      flags: VkPipelineDynamicStateCreateFlags = 0
    ) -> VkPipelineDynamicStateCreateInfo
    {
      var pipelineDynamicStateCreateInfo = VkPipelineDynamicStateCreateInfo()
      pipelineDynamicStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
      pipelineDynamicStateCreateInfo.pDynamicStates = UnsafePointer<VkDynamicState>(Array<VkDynamicState>(pDynamicStates).withUnsafeBufferPointer { $0.baseAddress })
      pipelineDynamicStateCreateInfo.dynamicStateCount = UInt32(pDynamicStates.size())
      pipelineDynamicStateCreateInfo.flags = flags
      return pipelineDynamicStateCreateInfo
    }

    @inline(__always)
    static func pipelineTessellationStateCreateInfo(patchControlPoints: UInt32) -> VkPipelineTessellationStateCreateInfo
    {
      var pipelineTessellationStateCreateInfo = VkPipelineTessellationStateCreateInfo()
      pipelineTessellationStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO
      pipelineTessellationStateCreateInfo.patchControlPoints = patchControlPoints
      return pipelineTessellationStateCreateInfo
    }

    @inline(__always)
    static func pipelineCreateInfo(
      layout: VkPipelineLayout,
      renderPass: VkRenderPass,
      flags: VkPipelineCreateFlags = 0
    ) -> VkGraphicsPipelineCreateInfo
    {
      var pipelineCreateInfo = VkGraphicsPipelineCreateInfo()
      pipelineCreateInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
      pipelineCreateInfo.layout = layout
      pipelineCreateInfo.renderPass = renderPass
      pipelineCreateInfo.flags = flags
      pipelineCreateInfo.basePipelineIndex = -1
      pipelineCreateInfo.basePipelineHandle = VkPipeline(bitPattern: 0)
      return pipelineCreateInfo
    }

    @inline(__always)
    static func pipelineCreateInfo() -> VkGraphicsPipelineCreateInfo
    {
      var pipelineCreateInfo = VkGraphicsPipelineCreateInfo()
      pipelineCreateInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
      pipelineCreateInfo.basePipelineIndex = -1
      pipelineCreateInfo.basePipelineHandle = VkPipeline(bitPattern: 0)
      return pipelineCreateInfo
    }

    @inline(__always)
    static func computePipelineCreateInfo(
      layout: VkPipelineLayout,
      flags: VkPipelineCreateFlags = 0
    ) -> VkComputePipelineCreateInfo
    {
      var computePipelineCreateInfo = VkComputePipelineCreateInfo()
      computePipelineCreateInfo.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO
      computePipelineCreateInfo.layout = layout
      computePipelineCreateInfo.flags = flags
      return computePipelineCreateInfo
    }

    @inline(__always)
    static func pushConstantRange(
      stageFlags: VkShaderStageFlags,
      size: UInt32,
      offset: UInt32
    ) -> VkPushConstantRange
    {
      var pushConstantRange = VkPushConstantRange()
      pushConstantRange.stageFlags = stageFlags
      pushConstantRange.offset = offset
      pushConstantRange.size = size
      return pushConstantRange
    }

    @inline(__always)
    static func bindSparseInfo() -> VkBindSparseInfo
    {
      var bindSparseInfo = VkBindSparseInfo()
      bindSparseInfo.sType = VK_STRUCTURE_TYPE_BIND_SPARSE_INFO
      return bindSparseInfo
    }

    /** @brief Initialize a map entry for a shader specialization constant */
    @inline(__always)
    static func specializationMapEntry(
      constantID: UInt32,
      offset: UInt32,
      size: Int
    ) -> VkSpecializationMapEntry
    {
      var specializationMapEntry = VkSpecializationMapEntry()
      specializationMapEntry.constantID = constantID
      specializationMapEntry.offset = offset
      specializationMapEntry.size = size
      return specializationMapEntry
    }

    /** @brief Initialize a specialization constant info structure to pass to a shader stage */
    @inline(__always)
    static func specializationInfo(
      mapEntryCount: UInt32,
      mapEntries: UnsafePointer<VkSpecializationMapEntry>,
      dataSize: Int,
      data: UnsafeRawPointer
    ) -> VkSpecializationInfo
    {
      var specializationInfo = VkSpecializationInfo()
      specializationInfo.mapEntryCount = mapEntryCount
      specializationInfo.pMapEntries = mapEntries
      specializationInfo.dataSize = dataSize
      specializationInfo.pData = data
      return specializationInfo
    }

    /** @brief Initialize a specialization constant info structure to pass to a shader stage */
    @inline(__always)
    static func specializationInfo(
      mapEntries: VkSpecializationMapEntryVec,
      dataSize: Int,
      data: UnsafeRawPointer
    ) -> VkSpecializationInfo
    {
      var specializationInfo = VkSpecializationInfo()
      specializationInfo.mapEntryCount = UInt32(mapEntries.size())
      specializationInfo.pMapEntries = UnsafePointer<VkSpecializationMapEntry>(Array<VkSpecializationMapEntry>(mapEntries).withUnsafeBufferPointer { $0.baseAddress })
      specializationInfo.dataSize = dataSize
      specializationInfo.pData = data
      return specializationInfo
    }

    /// Ray tracing related
    @inline(__always)
    static func accelerationStructureGeometryKHR() -> VkAccelerationStructureGeometryKHR
    {
      var accelerationStructureGeometryKHR = VkAccelerationStructureGeometryKHR()
      accelerationStructureGeometryKHR.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR
      return accelerationStructureGeometryKHR
    }

    @inline(__always)
    static func accelerationStructureBuildGeometryInfoKHR() -> VkAccelerationStructureBuildGeometryInfoKHR
    {
      var accelerationStructureBuildGeometryInfoKHR = VkAccelerationStructureBuildGeometryInfoKHR()
      accelerationStructureBuildGeometryInfoKHR.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR
      return accelerationStructureBuildGeometryInfoKHR
    }

    @inline(__always)
    static func accelerationStructureBuildSizesInfoKHR() -> VkAccelerationStructureBuildSizesInfoKHR
    {
      var accelerationStructureBuildSizesInfoKHR = VkAccelerationStructureBuildSizesInfoKHR()
      accelerationStructureBuildSizesInfoKHR.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
      return accelerationStructureBuildSizesInfoKHR
    }

    @inline(__always)
    static func rayTracingShaderGroupCreateInfoKHR() -> VkRayTracingShaderGroupCreateInfoKHR
    {
      var rayTracingShaderGroupCreateInfoKHR = VkRayTracingShaderGroupCreateInfoKHR()
      rayTracingShaderGroupCreateInfoKHR.sType = VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR
      return rayTracingShaderGroupCreateInfoKHR
    }

    @inline(__always)
    static func rayTracingPipelineCreateInfoKHR() -> VkRayTracingPipelineCreateInfoKHR
    {
      var rayTracingPipelineCreateInfoKHR = VkRayTracingPipelineCreateInfoKHR()
      rayTracingPipelineCreateInfoKHR.sType = VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR
      return rayTracingPipelineCreateInfoKHR
    }

    @inline(__always)
    static func writeDescriptorSetAccelerationStructureKHR() -> VkWriteDescriptorSetAccelerationStructureKHR
    {
      var writeDescriptorSetAccelerationStructureKHR = VkWriteDescriptorSetAccelerationStructureKHR()
      writeDescriptorSetAccelerationStructureKHR.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR
      return writeDescriptorSetAccelerationStructureKHR
    }
  }
}
