<template>
    <div class="w-full overflow-hidden bg-gray-50 pb-12">
      <div class="relative">
        <div 
          class="flex transition-transform duration-1000 ease-linear"
          :style="{ transform: `translateX(${-currentPosition}px)` }"
          @pointerdown="startDrag"
            @pointermove="onDrag"
            @pointerup="endDrag"
            @pointerleave="endDrag"
      >
        >
          <div 
            v-for="(testimonial, index) in [...testimonials, ...testimonials]" 
            :key="`${index}-${testimonial.name}`"
            class="min-w-[400px] mx-4"
          >
            <div class="bg-white p-6 rounded-lg shadow-sm">
              <div class="flex items-center mb-4">
                <img 
                  :src="testimonial.image" 
                  :alt="testimonial.name"
                  class="w-16 h-16 rounded-full object-cover"
                />
                <div class="ml-4">
                  <h3 class="font-semibold text-lg">{{ testimonial.name }}</h3>
                  <p class="text-gray-600 text-sm">{{ testimonial.role }}</p>
                </div>
              </div>
              <p class="text-gray-700 text-sm leading-relaxed">{{ testimonial.quote }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import Image1 from '../../assets/1.webp';
    import Image2 from '../../assets/2.webp';
    import Image3 from '../../assets/3.webp';
    import Image4 from '../../assets/4.webp';
    import Image5 from '../../assets/5.webp';
  import { ref, onMounted, onUnmounted } from 'vue'
  
  const testimonials = [
    {
      name: 'Thầy Nguyễn Hữu Tòn',
      role: 'Nguyên Trưởng khoa Không lưu (nay là khoa Khai thác hàng không)',
      quote: '"Để có học trò giỏi, ngoài việc có phương tiện, máy móc tốt, cách học tốt, phải có người thầy người cô giỏi luôn tận tâm và thương học trò.Giáo viên phải nghĩ rằng, giảng dạy như thế nào để học trò của mình không thua ai dù ở trong nước hay đi nước ngoài"',
      image: Image1
    },
    {
      name: 'Anh Trịnh Ngọc Khánh',
      role: 'Cựu sinh viên khoa Không lưu (2008-2013)',
      quote: 'Sự nghiệp thành công và những đóng góp quan trọng của anh trong ngành hàng không không chỉ phản ánh sự nỗ lực cá nhân mà còn là niềm tự hào của Khoa Khai thác hàng không, minh chứng cho chất lượng đào tạo và sự phát triển của thế hệ sinh viên ưu tú Học viện hàng không Việt Nam.',
      image: Image2
    },
    {
      name: 'Nguyễn Ngọc Ý',
      role: 'Kiểm soát viên không lưu - Vietnam Airline, sinh viên K19',
      quote: 'Tôi yêu Học viện. Học viện là nơi để về.',
      image: Image3
    }
  ]
  
  const currentPosition = ref(0)
  const animationFrame = ref(null)
  const SCROLL_SPEED = 0.3 // pixels per frame
  const startX = ref(0)
const isDragging = ref(false)
  
  const animate = () => {
    currentPosition.value += SCROLL_SPEED
    
    // Reset position when all slides have been shown
    const totalWidth = testimonials.length * 416 // 400px width + 16px margin
    if (currentPosition.value >= totalWidth) {
      currentPosition.value = 0
    }
    
    animationFrame.value = requestAnimationFrame(animate)
  }
  
  onMounted(() => {
    animationFrame.value = requestAnimationFrame(animate)
  })
  
  onUnmounted(() => {
    if (animationFrame.value) {
      cancelAnimationFrame(animationFrame.value)
    }
  })
  const startDrag = (event) => {
  isDragging.value = true
  startX.value = event.pageX || event.touches[0].pageX
}

const onDrag = (event) => {
  if (!isDragging.value) return
  const currentX = event.pageX || event.touches[0].pageX
  const diff = startX.value - currentX
  currentPosition.value += diff
  startX.value = currentX
}

const endDrag = () => {
  isDragging.value = false
  const totalWidth = testimonials.length * 416
  if (currentPosition.value < 0) {
    currentPosition.value = 0
  } else if (currentPosition.value > totalWidth) {
    currentPosition.value = 0
  }
}
  </script>

<style scoped>
div {
  user-select: none;
}
</style>