#ifndef __VULKANKIT_VULKAN_H__
#define __VULKANKIT_VULKAN_H__

#include <vulkan/vulkan.h>
#include <vector>
#include <chrono>
#include <ratio>

/* ---------------------------------------- */

/**
 * Vulkan Aliases
 *
 * These types are used to represent each
 * of the Vulkan vector types in Swift. */

/* ---------------------------------------- */

using VkDescriptorPoolSizeVec = std::vector<VkDescriptorPoolSize>;
using VkDescriptorSetLayoutBindingVec = std::vector<VkDescriptorSetLayoutBinding>;
using VkVertexInputBindingDescriptionVec = std::vector<VkVertexInputBindingDescription>;
using VkVertexInputAttributeDescriptionVec = std::vector<VkVertexInputAttributeDescription>;
using VkDynamicStateVec = std::vector<VkDynamicState>;
using VkSpecializationMapEntryVec = std::vector<VkSpecializationMapEntry>;
using VkBufferImageCopyVec = std::vector<VkBufferImageCopy>;

/* ---------------------------------------- */

/**
 * Wabi Standard Library
 * These functions are used to extend the
 * standard library with some additional
 * template specializations and functions
 * for use with swift. */

/* ---------------------------------------- */

namespace wabi
{
  using namespace std;

  namespace std
  {
    using milliseconds = chrono::duration<double, milli>;

    milliseconds duration(const chrono::nanoseconds &__d)
    {
      return chrono::duration<double, milli>(__d);
    }

    chrono::nanoseconds operator-(
      const chrono::steady_clock::time_point &__t1, 
      const chrono::steady_clock::time_point &__t2
    )
    {
      return __t1 - __t2;
    }
  } /* namespace wabi.std */
} /* namespace wabi */

/* ---------------------------------------- */

/**
 * Vulkan API Version Functions
 * These functions are used to extract the
 * major, minor, and patch versions from
 * the Vulkan API version number. */

/* ---------------------------------------- */

uint32_t vkApiVersion1_0()
{
  return VK_API_VERSION_1_0;
}

uint32_t vkApiVersion1_3()
{
  return VK_API_VERSION_1_3;
}

uint32_t vkApiVersionMajor(uint32_t v)
{
  return VK_API_VERSION_MAJOR(v);
}

uint32_t vkApiVersionMinor(uint32_t v)
{
  return VK_API_VERSION_MINOR(v);
}

uint32_t vkApiVersionPatch(uint32_t v)
{
  return VK_API_VERSION_PATCH(v);
}

/* ---------------------------------------- */

/**
 * Vulkan API Definitions
 * These definitions are used to represent
 * the various Vulkan API constants in Swift. */

#define VK_FLAGS_NONE 0
#define DEFAULT_FENCE_TIMEOUT 100000000000

/* ---------------------------------------- */

#endif // __VULKANKIT_VULKAN_H__
