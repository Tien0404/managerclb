<template>
  <div class="loading-container" :class="{ overlay: isOverlay }">
    <div class="loading-content">
      <div class="loading-spinner"></div>
      <p v-if="message" class="loading-text" v-text="message"></p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoadingSpinner',
  props: {
    message: {
      type: String,
      default: 'Loading...'
    },
    isOverlay: {
      type: Boolean,
      default: false
    }
  }
}
</script>

<style scoped>
.loading-container {
  @apply flex items-center justify-center;
}

.loading-container.overlay {
  @apply fixed inset-0 bg-black bg-opacity-50 z-50;
}

.loading-content {
  @apply flex flex-col items-center justify-center space-y-4;
}

.loading-text {
  @apply text-primary font-medium mt-2;
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

.loading-container.overlay .loading-text {
  @apply text-white;
}
</style> 