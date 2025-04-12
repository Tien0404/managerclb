<template>
  <Transition name="fade">
    <div v-if="show" 
      class="fixed top-4 right-4 z-50 max-w-sm w-full"
      :class="notificationClasses">
      <div class="flex items-center p-4 rounded-lg shadow-lg">
        <!-- Icon -->
        <div class="flex-shrink-0">
          <CheckCircle v-if="type === 'success'" class="w-6 h-6 text-white" />
          <XCircle v-else-if="type === 'error'" class="w-6 h-6 text-white" />
          <AlertTriangle v-else-if="type === 'warning'" class="w-6 h-6 text-white" />
          <Info v-else class="w-6 h-6 text-white" />
        </div>

        <!-- Message -->
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-white">
            {{ message }}
          </p>
        </div>

        <!-- Close Button -->
        <div class="ml-4 flex-shrink-0">
          <button
            type="button"
            class="inline-flex text-white hover:text-white/80 focus:outline-none"
            @click="hideNotification"
          >
            <span class="sr-only">Đóng</span>
            <X class="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { computed, watch } from 'vue'
import { CheckCircle, XCircle, AlertTriangle, Info, X } from 'lucide-vue-next'

const props = defineProps({
  type: {
    type: String,
    default: 'success',
    validator: (value) => ['success', 'error', 'warning', 'info'].includes(value)
  },
  message: {
    type: String,
    required: true
  },
  duration: {
    type: Number,
    default: 5000
  },
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:show'])

const notificationClasses = computed(() => {
  const baseClasses = 'transform transition-all duration-300 ease-in-out'
  const typeClasses = {
    success: 'bg-green-500',
    error: 'bg-red-500',
    warning: 'bg-yellow-500',
    info: 'bg-blue-500'
  }
  return `${baseClasses} ${typeClasses[props.type]}`
})

const hideNotification = () => {
  emit('update:show', false)
}

// Auto-hide notification after duration
watch(() => props.show, (newValue) => {
  if (newValue && props.duration > 0) {
    setTimeout(() => {
      hideNotification()
    }, props.duration)
  }
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-1rem);
}
</style> 