<template>
  <div class="app-container">
    <router-view v-slot="{ Component }">
      <transition name="page" mode="out-in">
        <component :is="Component" />
      </transition>
    </router-view>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
.app-container {
  @apply min-h-screen bg-gradient-to-br from-white to-gray-50;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  @apply w-2;
}

::-webkit-scrollbar-track {
  @apply bg-gray-100;
}

::-webkit-scrollbar-thumb {
  @apply bg-primary bg-opacity-50 rounded-full;
}

::-webkit-scrollbar-thumb:hover {
  @apply bg-primary bg-opacity-75;
}

/* Disable text selection during transitions */
.page-enter-active *,
.page-leave-active * {
  user-select: none;
}
</style>
