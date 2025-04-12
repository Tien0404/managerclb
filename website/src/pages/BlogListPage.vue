<template>
  <div class="relative overflow-hidden min-h-screen bg-gradient-to-br from-yellow-50 to-amber-50">
    <!-- Enhanced Dynamic Background with Blob Animations -->
    <div class="absolute inset-0 overflow-hidden">
      <!-- Decorative Blobs with Enhanced Animation -->
      <div
        class="absolute top-0 left-0 w-72 h-72 bg-yellow-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob transform-gpu">
      </div>
      <div
        class="absolute top-0 right-0 w-72 h-72 bg-amber-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000 transform-gpu">
      </div>
      <div
        class="absolute -bottom-8 left-20 w-72 h-72 bg-orange-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000 transform-gpu">
      </div>

      <!-- Enhanced Flowing Background Animation -->
      <div class="absolute inset-0">
        <div
          class="absolute inset-0 bg-gradient-to-r from-yellow-400/20 via-yellow-300/20 to-yellow-400/20 animate-flow transform-gpu">
        </div>
        <div
          class="absolute inset-0 bg-gradient-to-r from-yellow-300/10 via-yellow-400/10 to-yellow-300/10 animate-flow-slow transform-gpu">
        </div>
        <div
          class="absolute inset-0 bg-gradient-to-r from-yellow-500/10 via-yellow-400/10 to-yellow-500/10 animate-flow-slower transform-gpu">
        </div>
      </div>

      <!-- Enhanced Wave Pattern -->
      <div class="absolute inset-0 transform-gpu">
        <div class="wave"></div>
        <div class="wave wave-delayed"></div>
        <div class="wave wave-delayed-2"></div>
      </div>

      <!-- Enhanced Particle Effects -->
      <div class="absolute inset-0">
        <div class="particles yellow-particles"></div>
      </div>
    </div>

    <!-- Main Content with Enhanced Animations -->
    <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Enhanced Title Section -->
      <div class="relative mb-12 text-center" data-aos="fade-down" data-aos-delay="100">
        <div
          class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-64 h-1 bg-gradient-to-r from-transparent via-yellow-400 to-transparent animate-pulse">
        </div>
        <h1 class="text-4xl font-bold text-gray-900 glow-text-strong relative inline-block animate-gradient">
          Tin tức
          <div
            class="absolute top-0 left-0 w-6 h-6 border-t-2 border-l-2 border-yellow-400 transform -translate-x-3 -translate-y-3 animate-border-flow">
          </div>
          <div
            class="absolute top-0 right-0 w-6 h-6 border-t-2 border-r-2 border-yellow-400 transform translate-x-3 -translate-y-3 animate-border-flow animation-delay-500">
          </div>
        </h1>
        <div
          class="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1/2 w-40 h-1 bg-gradient-to-r from-transparent via-yellow-400 to-transparent animate-pulse">
        </div>
      </div>
      <div class="flex flex-col lg:flex-row gap-12">
        <!-- Enhanced Sidebar -->
        <div class="lg:w-72 flex-shrink-0" data-aos="fade-right" data-aos-delay="200">
          <div
            class="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg hover:shadow-2xl transition-all duration-500 group">
            <div class="p-4 bg-gradient-to-r from-yellow-50 to-amber-50 border-b relative">
              <span class="font-medium text-yellow-600">Danh mục</span>
              <div
                class="absolute bottom-0 left-0 w-full h-0.5 bg-gradient-to-r from-yellow-400 to-amber-400 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300">
              </div>
            </div>
            <div class="p-4 space-y-2">
              <button v-for="(category, index) in categories" :key="category.id"
                @click="handleCategoryClick(category.id)"
                class="w-full flex items-center gap-3 p-2 rounded-lg transition-all duration-300 transform hover:scale-102 group/item"
                :class="[
                  selectedCategory === category.id
                    ? 'bg-yellow-50 text-yellow-600'
                    : 'text-gray-700 hover:bg-yellow-50/50'
                ]" :data-aos="'fade-left'" :data-aos-delay="200 + (index * 100)">
                <div class="w-8 h-8 rounded-full flex items-center justify-center transition-colors" :class="[
                  selectedCategory === category.id
                    ? 'bg-yellow-100'
                    : 'bg-yellow-50 group-hover/item:bg-yellow-100'
                ]">
                  <div class="w-4 h-4 rounded-full" :class="[
                    selectedCategory === category.id
                      ? 'bg-yellow-400'
                      : 'bg-yellow-300 group-hover/item:bg-yellow-400'
                  ]">
                  </div>
                </div>
                <span class="flex-1 text-left">{{ category.name }}</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Blog List -->
        <BlogList :showActions="false" />

      </div>
    </div>
  </div>
</template>

<script setup>
import { CalendarIcon, SearchIcon, ChevronDown, XCircle, InboxIcon } from 'lucide-vue-next'
import { ref, onMounted, computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useBlogStore } from '../stores/blogStore'
import BlogList from "../components/ClubManage/BlogManage/BlogList.vue";

import AOS from 'aos'
import 'aos/dist/aos.css'

const blogStore = useBlogStore();
const { blogs, isLoading, error } = storeToRefs(blogStore);
const { fetchBlogs, setFilter } = blogStore;

// Local state
const searchQuery = ref('');
const selectedCategory = ref(null);
const currentPage = ref(1);
const itemsPerPage = 10;

// Computed
const filteredBlogs = computed(() => {
    return blogStore.filteredBlogs;
});

const hasMoreItems = computed(() => {
    return currentPage.value * itemsPerPage < filteredBlogs.value.length;
});

// Methods
const initializeData = async () => {
    try {
        await fetchBlogs();
    } catch (err) {
        console.error('Failed to fetch blogs:', err);
    }
};

const handleCategoryClick = (categoryId) => {
    selectedCategory.value = categoryId;
    setFilter('category', categoryId);
};

onMounted(() => {
    initializeData();
    AOS.init({
        duration: 800,
        easing: 'ease-out-cubic',
        once: true,
        mirror: false,
        anchorPlacement: 'top-bottom'
    });
});

const categories = [
    { id: 23, name: 'Thông tin tuyển sinh', href: '#', current: true },
    { id: 24, name: 'Tư vấn chọn khối thi', href: '#', current: false },
    { id: 25, name: 'Tư vấn chọn ngành', href: '#', current: false }
];
</script>

<style scoped>
@keyframes flow {
  0% {
    transform: translateX(-50%);
  }

  100% {
    transform: translateX(50%);
  }
}

.animate-flow {
  animation: flow 10s linear infinite;
}

.animate-flow-slow {
  animation: flow 12s linear infinite;
}

.animate-flow-slower {
  animation: flow 15s linear infinite;
}

@keyframes wave {
  0% {
    transform: translateX(-100%) translateY(0) rotate(0);
  }

  50% {
    transform: translateX(0) translateY(-15px) rotate(1deg);
  }

  100% {
    transform: translateX(100%) translateY(0) rotate(0);
  }
}

.wave {
  position: absolute;
  width: 200%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(234, 179, 8, 0.1), transparent);
  animation: wave 6s linear infinite;
}

.wave-delayed {
  animation-delay: -2s;
  opacity: 0.7;
}

.wave-delayed-2 {
  animation-delay: -4s;
  opacity: 0.5;
}

.particles {
  animation: particle-pulse 3s ease-in-out infinite;
}

@keyframes particle-pulse {

  0%,
  100% {
    opacity: 0.2;
  }

  50% {
    opacity: 0.5;
  }
}

.yellow-particles {
  background: radial-gradient(circle at center,
      rgba(234, 179, 8, 0.1) 0%,
      transparent 60%);
}

/* Enhanced Title Styles */
.glow-text-strong {
  text-shadow:
    0 0 10px rgba(234, 179, 8, 0.3),
    0 0 20px rgba(234, 179, 8, 0.2),
    0 0 30px rgba(234, 179, 8, 0.1),
    2px 2px 2px rgba(0, 0, 0, 0.1);
  position: relative;
  z-index: 1;
}

h1.glow-text-strong::before {
  content: '';
  position: absolute;
  inset: -10px -20px;
  background: radial-gradient(circle at center, rgba(255, 255, 255, 0.9) 0%, transparent 70%);
  z-index: -1;
  opacity: 0.8;
}

/* Enhanced Animations */
@keyframes border-flow {
  0% {
    border-color: rgba(234, 179, 8, 0.4);
  }

  50% {
    border-color: rgba(234, 179, 8, 1);
  }

  100% {
    border-color: rgba(234, 179, 8, 0.4);
  }
}

.animate-border-flow {
  animation: border-flow 1.5s ease-in-out infinite;
}

.animation-delay-500 {
  animation-delay: 0.5s;
}

@keyframes blob {

  0%,
  100% {
    transform: translate(0, 0) scale(1) rotate(0deg);
  }

  25% {
    transform: translate(15px, -15px) scale(1.05) rotate(3deg);
  }

  50% {
    transform: translate(0, 15px) scale(1) rotate(0deg);
  }

  75% {
    transform: translate(-15px, -15px) scale(0.95) rotate(-3deg);
  }
}

.animate-blob {
  animation: blob 10s infinite cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes gradient {
  0% {
    background-position: 0% 50%;
  }

  50% {
    background-position: 100% 50%;
  }

  100% {
    background-position: 0% 50%;
  }
}

.animate-gradient {
  background-size: 200% auto;
  animation: gradient 3s linear infinite;
}

/* Enhanced Hover Effects */
.hover-lift {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.hover-lift:hover {
  transform: translateY(-5px);
}

/* Enhanced Card Styles */
.card-shadow {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: box-shadow 0.3s ease-in-out;
}

.card-shadow:hover {
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

/* Smooth Scrolling */
html {
  scroll-behavior: smooth;
}

/* Custom Scrollbar */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: linear-gradient(to bottom, #fef3c7, #fff7ed);
}

::-webkit-scrollbar-thumb {
  background: linear-gradient(to bottom, #fbbf24, #f59e0b);
  border-radius: 4px;
  transition: all 0.3s ease;
}

::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(to bottom, #f59e0b, #d97706);
}

/* Transition speeds */
.transition-all {
  transition-duration: 300ms;
}

.hover\:scale-105:hover {
  transition-duration: 200ms;
}

.group-hover\:opacity-100 {
  transition-duration: 200ms;
}

.group-hover\:scale-125 {
  transition-duration: 500ms;
}

@keyframes shimmer {
  0% {
    transform: translateX(-200%);
  }

  100% {
    transform: translateX(200%);
  }
}

.animate-shimmer {
  animation: shimmer 2s ease-in-out infinite;
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-up {
  animation: slide-up 0.5s ease-out forwards;
}

.transition-all {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 500ms;
}

.duration-500 {
  transition-duration: 500ms;
}

.duration-700 {
  transition-duration: 700ms;
}

.transform-gpu {
  transform: translate3d(0, 0, 0);
  backface-visibility: hidden;
  perspective: 1000px;
}
</style>
