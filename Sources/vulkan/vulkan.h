#ifndef __VULKANKIT_VULKAN_H__
#define __VULKANKIT_VULKAN_H__

#include <vulkan/vulkan.h>

uint32_t vkApiVersion1_0()
{
  return VK_API_VERSION_1_0;
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

#endif // __VULKANKIT_VULKAN_H__
