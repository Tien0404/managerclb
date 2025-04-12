<template>
  <div class="relative inline-block dropdown-menu">
    <button @click="toggleDropdown" class="dropdown-trigger">
      <slot name="trigger">
        <span class="px-4 py-2 bg-gray-200 rounded-lg">Open</span>
      </slot>
    </button>

    <div
      v-if="isDropdownOpen"
      class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg z-10">
      <ul>
        <li
          v-for="(item, index) in options"
          :key="index"
          @click="selectOption(item)"
          class="px-4 py-2 hover:bg-gray-100 flex items-center cursor-pointer text-black"
          :class="{ 'text-red-500 hover:text-red-600': item.danger }">
          <component
            :is="item.icon"
            class="w-5 h-5 text-black mr-3"
            :class="{ 'text-red-500 hover:text-red-600': item.danger }"
          />
          {{ item.label }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import { User, Settings, LogOut } from 'lucide-vue-next';

const openDropdownId = ref(null);

export default {
  props: {
    options: {
      type: Array,
      default: () => [
        { label: "Profile", icon: User },
        { label: "Settings", icon: Settings },
        { label: "Logout", icon: LogOut },
      ],
    },
  },
  data() {
    return {
      isDropdownOpen: false,
      dropdownId: Math.random().toString(36).substr(2, 9), 
    };
  },
  methods: {
    toggleDropdown() {
      // Đóng dropdown khác nếu đang mở
      if (openDropdownId.value && openDropdownId.value !== this.dropdownId) {
        openDropdownId.value = this.dropdownId;
        this.isDropdownOpen = true;
      } else {
        this.isDropdownOpen = !this.isDropdownOpen;
        openDropdownId.value = this.isDropdownOpen ? this.dropdownId : null;
      }
    },
    selectOption(item) {
      this.$emit('select', item);
      openDropdownId.value = null;
      this.isDropdownOpen = false;
    },
    handleClickOutside(event) {
      if (!event.target.closest('.dropdown-menu') &&
          !event.target.closest('.dropdown-trigger')) {
        openDropdownId.value = null;
        this.isDropdownOpen = false;
      }
    }
  },
  mounted() {
    document.addEventListener('click', this.handleClickOutside);
  },
  beforeUnmount() {
    document.removeEventListener('click', this.handleClickOutside);
  },
};
</script>
