<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <div v-if="loading" class="flex justify-center items-center h-screen">
      <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
    </div>

    <div v-else-if="error" class="flex justify-center items-center h-screen">
      <div class="text-red-500">{{ error }}</div>
    </div>

    <div v-else>
      <!-- Header -->
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-xl font-semibold">Quản lý Trang đại diện</h1>
        <div class="flex gap-3">
        </div>
      </div>

      <!-- Hero Section -->
      <div class="container mx-auto px-4 py-8">
        <div class="flex items-start gap-8">
          <div class="max-w-6xl mx-auto flex">
            <!-- Club Information -->
            <div class="w-1/2 p-8">
              <h2 class="text-3xl font-bold mb-6">{{ club.name }}</h2>
              <div class="flex mb-4">
                <div class="mr-8">
                  <p class="text-3xl font-bold text-blue-500">{{ club.member_count }}+</p>
                  <p class="text-gray-500">Thành viên</p>
                </div>
                <div>
                  <p class="text-3xl font-bold text-blue-500">{{ club.events?.length || 0 }}</p>
                  <p class="text-gray-500">Sự kiện</p>
                </div>
              </div>
            </div>

            <!-- Club Images -->
            <div class="w-1/2 grid grid-cols-3 gap-4 p-4">
              <img 
                v-for="image in club.background_images" 
                :key="image.id" 
                :src="image.image_url" 
                class="rounded-lg object-cover h-32 w-full" 
                :alt="club.name"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- About Section -->
      <section class="py-12 bg-gray-50">
        <div class="container mx-auto px-4">
          <div class="max-w-6xl mx-auto">
            <h2 class="text-3xl font-bold mb-4">Chúng tôi là ai</h2>
            <div class="flex gap-4 mb-6">
              <span class="px-4 py-2 bg-blue-50 text-blue-600 rounded-full text-sm flex items-center gap-2">
                <PaletteIcon class="w-4 h-4" />
                {{ clubCategory?.name }}
              </span>
            </div>
            <p class="text-gray-600 mb-8">
              {{ club.description }}
            </p>
          </div>
        </div>
      </section>

      <!-- Past Events -->
      <section class="py-12">
        <div class="container mx-auto px-4">
          <h2 class="text-xl font-semibold mb-6">Sự kiện đã tổ chức</h2>
          <div class="grid md:grid-cols-3 gap-8">
            <div v-for="event in club.events" :key="event.id" class="bg-white rounded-lg overflow-hidden shadow-lg">
              <img 
                :src="event.background_images?.[0]?.image_url" 
                :alt="event.name" 
                class="w-full h-48 object-cover"
              />
              <div class="p-6">
                <span class="text-sm text-blue-500">{{ event.status }}</span>
                <h3 class="text-xl font-semibold mt-2">{{ event.name }}</h3>
                <p class="text-gray-600 mt-2">
                  {{ event.content || 'Không có mô tả' }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Management Team -->
      <section class="py-12 bg-gray-50">
        <div class="container mx-auto px-4">
          <h2 class="text-xl font-semibold mb-6">Ban quản trị Câu Lạc Bộ</h2>
          <p class="text-gray-600 mb-6">Những người đứng sau sự thành công của CLB</p>
          <Slider />
          <!-- <button class="bg-blue-500 text-white px-4 py-2 rounded-lg mb-8">
            Xem thêm
          </button> -->

          <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
            <div v-for="member in managementTeam" :key="member.id" class="text-center">
              <img :src="member.avatar" :alt="member.name" class="w-32 h-32 rounded-lg mx-auto mb-2 object-cover" />
              <h3 class="font-medium">{{ member.name }}</h3>
              <p class="text-sm text-gray-500">{{ member.role }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Contact Form -->
      <section class="py-12 bg-gray-50">
        <div class="container mx-auto px-4">
          <div class="max-w-4xl mx-auto grid md:grid-cols-2 gap-8 bg-gradient-to-r bg-gradient-to-b from-blue-600 to-blue-200 rounded-lg p-8 text-white">
            <div>
              <h2 class="text-xl font-semibold mb-4">Liên hệ tài trợ</h2>
              <p class="mb-4">Hãy để lại thông tin để chúng tôi có thể liên hệ với bạn</p>
              <div class="space-y-2">
                <p>{{ club.contact_email || 'Chưa có email' }}</p>
                <p>{{ club.contact_phone || 'Chưa có số điện thoại' }}</p>
              </div>
              <div class="mt-4" v-if="club.facebook_link">
                <a :href="club.facebook_link" target="_blank" rel="noopener noreferrer">
                  <FacebookIcon class="w-6 h-6" />
                </a>
              </div>
            </div>

            <form class="space-y-4 bg-white rounded-lg p-6 shadow-md">
              <input type="text" placeholder="Họ và tên" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500" />
              <input type="tel" placeholder="Số điện thoại" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500" />
              <input type="email" placeholder="Email" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500" />
              <textarea rows="4" placeholder="Nội dung" class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500"></textarea>
              <button type="submit" class="bg-white border border-gray-300 text-blue-600 px-6 py-2 rounded-lg hover:bg-gray-100">
                Gửi
              </button>
            </form>
          </div>
        </div>
      </section>

      <!-- Club Members -->
      <section class="py-12 bg-gray-50">
        <div class="container mx-auto px-4">
          <h2 class="text-xl font-semibold text-center mb-2">Thành viên Câu Lạc Bộ</h2>
          <p class="text-gray-600 text-center mb-8">Cùng lắng nghe họ nói gì về CLB</p>
          <Comment />

          <!-- Testimonials -->
          <div class="grid md:grid-cols-3 gap-8">
            <div v-for="testimonial in testimonials" :key="testimonial.id" class="text-center">
              <div class="text-6xl text-gray-200 mb-4">"</div>
              <img :src="testimonial.avatar" :alt="testimonial.name" class="w-20 h-20 mx-auto mb-4" />
              <p class="text-gray-600 mb-4">{{ testimonial.quote }}</p>
              <h3 class="font-medium">{{ testimonial.name }}</h3>
              <p class="text-sm text-gray-500">{{ testimonial.role }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Modal -->
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import {
  FileTextIcon,
  PenIcon,
  TargetIcon,
  PaletteIcon,
  GraduationCapIcon,
  FacebookIcon
} from 'lucide-vue-next';
import Slider from '../../components/ClubManage/Slider.vue';
import Comment from '../../components/ClubManage/Comment.vue';
import clubService from '../../services/club';
import { useCategoryStore } from '../../stores/categoryStore';

const route = useRoute();
const categoryStore = useCategoryStore();
const isModalOpen = ref(false);
const club = ref(null);
const loading = ref(true);
const error = ref(null);

// Computed property for club category
const clubCategory = computed(() => {
  if (club.value?.category_id) {
    return categoryStore.getCategoryById(club.value.category_id);
  }
  return null;
});

async function fetchClubData() {
  try {
    loading.value = true;
    const clubId = route.params.id;
    if (!clubId) {
      throw new Error('Không tìm thấy ID của câu lạc bộ');
    }
    const data = await clubService.getClubById(clubId);
    club.value = data;
  } catch (err) {
    error.value = err.message;
    console.error('Error fetching club data:', err);
  } finally {
    loading.value = false;
  }
}

function openModal() {
  isModalOpen.value = true;
}

function closeModal() {
  isModalOpen.value = false;
}

onMounted(async () => {
  // Fetch categories first
  await categoryStore.fetchCategories();
  // Then fetch club data
  await fetchClubData();
});
</script>

<style scoped>
header button {
  transition: background-color 0.3s;
}

header button:hover {
  background-color: #f3f4f6;
}
</style>