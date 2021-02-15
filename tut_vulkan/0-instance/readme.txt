Prior to instance creation a limited number of things are possible. Each of these demonstrate different aspects of Vulkan instance creation environment. When the instance is created the Vulkan loader also makes a number of decisions based on registry keys and environment variables.


A. null.fasmg
	Minimal creation requirements using the default feature set.

B. instance.fasmg
	Basic 1.0+ support for instance creation.

C. debug.fasmg
	Extended debug information from the very beginning.

D. enumerate.fasmg
	Examine layers and instance extensions prior to instance creation.




Layer selection process:
https://github.com/LunarG/VulkanTools/tree/master/vkconfig


Set layer JSON manifest file directory:
	VK_LAYER_PATH

Activate layers:
	VK_INSTANCE_LAYERS

