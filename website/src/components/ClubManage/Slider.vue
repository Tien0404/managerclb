<template>
  <div class="flex items-center justify-center">
    <div v-if="loading" class="text-center">
      <p>Loading...</p>
    </div>
    
    <div v-else-if="error" class="text-center text-red-500">
      <p>{{ error }}</p>
    </div>

    <div v-else-if="slides.length > 0" class="w-full max-w-7xl relative">
      <!-- Main slider container -->
      <div class="relative flex items-center justify-center gap-4 py-8">
        <!-- Navigation Arrows -->
        <button 
          @click="prevSlide" 
          class="absolute left-0 z-10 w-14 h-14 flex items-center justify-center bg-white/20 rounded-full hover:bg-white hover:text-black transition-all"
          aria-label="Previous slide"
        >
          <ChevronLeftIcon class="w-8 h-8" />
        </button>

        <!-- Slides -->
        <div class="flex items-center justify-center gap-4">
          <!-- Left Slide -->
          <div class="w-64 h-48 relative opacity-70 transition-all duration-500">
            <img 
              :src="slides[getPrevIndex()].image" 
              :alt="slides[getPrevIndex()].title"
              class="w-full h-full object-cover rounded-lg"
            />
          </div>

          <!-- Center Slide (Active) -->
          <div class="w-96 h-72 relative z-10 transition-all duration-500">
            <img 
              :src="slides[currentIndex].image" 
              :alt="slides[currentIndex].title"
              class="w-full h-full object-cover rounded-lg shadow-xl"
            />
            <div class="absolute bottom-0 left-0 right-0 bg-black bg-opacity-70 p-4 rounded-b-lg">
              <h3 class="text-[#FFA500] text-center font-medium">{{ slides[currentIndex].title }}</h3>
              <!-- <p class="text-white text-center text-sm">{{ slides[currentIndex].description }}</p> -->
              <p class="text-white text-center text-xs mt-1">{{ slides[currentIndex].role }}</p>
              <p v-if="slides[currentIndex].email" class="text-white text-center text-xs mt-1">
                {{ slides[currentIndex].email }}
              </p>
            </div>
          </div>

          <!-- Right Slide -->
          <div class="w-64 h-48 relative opacity-70 transition-all duration-500">
            <img 
              :src="slides[getNextIndex()].image" 
              :alt="slides[getNextIndex()].title"
              class="w-full h-full object-cover rounded-lg"
            />
          </div>
        </div>

        <button 
          @click="nextSlide" 
          class="absolute right-0 z-10 w-14 h-14 flex items-center justify-center bg-white/20 rounded-full hover:bg-white hover:text-black transition-all"
          aria-label="Next slide"
        >
          <ChevronRightIcon class="w-8 h-8" />
        </button>

        <div class="absolute bottom-0 left-0 right-0 flex justify-center gap-2 mt-4">
          <button 
            v-for="(_, index) in slides" 
            :key="index"
            @click="currentIndex = index"
            class="w-2 h-2 rounded-full"
            :class="currentIndex === index ? 'bg-blue-500' : 'bg-gray-300'"
          />
        </div>
      </div>
    </div>

    <div v-else class="text-center">
      <p>Không có dữ liệu phòng ban</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ChevronLeftIcon, ChevronRightIcon } from 'lucide-vue-next'
import { useDepartmentStore } from '../../stores/departmentStore'
import { storeToRefs } from 'pinia'
import { useRoute } from 'vue-router'

const route = useRoute()
const departmentStore = useDepartmentStore()
const { loading, error } = storeToRefs(departmentStore)

const slides = ref([])
const currentIndex = ref(0)

const defaultImage = '/path/to/default-image.jpg' // Add a default image path

onMounted(async () => {
  try {
    const clubId = route.params.id
    const response = await departmentStore.fetchClubDepartments(clubId)
    
    if (response) {
      const allSlides = []
      
      // Add club owner slide
      if (response.club?.owner) {
        allSlides.push({
          image: response.club.owner.background_images?.[0]?.image_url || defaultImage,
          title: response.club.owner.username || 'Unknown Owner',
          description: 'Chủ CLB',
          email: response.club.owner.email,
          role: 'Chủ CLB'
        })
      }

      // Add department slides
      if (response.departments && response.departments.length > 0) {
        const departmentSlides = response.departments.map(dept => ({
          image: dept.user?.background_images?.[0]?.image_url || defaultImage,
          title: dept.user?.username || 'Unknown User',
          description: dept.name || 'Thành viên phòng ban',
          email: dept.user?.email,
          role: 'Thành viên phòng ban'
        }))
        allSlides.push(...departmentSlides)
      }

      // Set slides
      slides.value = allSlides
    }
  } catch (error) {
    console.error('Error loading departments:', error)
  }
})

const nextSlide = () => {
  if (slides.value.length > 0) {
    currentIndex.value = (currentIndex.value + 1) % slides.value.length
  }
}

const prevSlide = () => {
  if (slides.value.length > 0) {
    currentIndex.value = currentIndex.value === 0 
      ? slides.value.length - 1 
      : currentIndex.value - 1
  }
}

const getNextIndex = () => {
  return slides.value.length > 0 ? (currentIndex.value + 1) % slides.value.length : 0
}

const getPrevIndex = () => {
  return slides.value.length > 0 
    ? (currentIndex.value === 0 ? slides.value.length - 1 : currentIndex.value - 1)
    : 0
}
</script>

<style scoped>
/* Add any additional custom styles here if needed */
</style>