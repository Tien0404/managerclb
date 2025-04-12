<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center min-h-screen">
      <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex justify-center items-center min-h-screen">
      <div class="text-center">
        <p class="text-red-500 text-xl mb-4">{{ error }}</p>
        <button @click="fetchClub" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
          Thử lại
        </button>
      </div>
    </div>

    <!-- Content when data is loaded -->
    <template v-else>
      <!-- Hero Section -->
      <div class="container mx-auto px-4 py-8">
        <div class="flex items-start gap-8">
          <div class="max-w-6xl mx-auto flex">
            <!-- Thông tin câu lạc bộ -->
            <div class="w-1/2 p-8">
              <h2 class="text-3xl font-bold mb-6">{{ club?.name || 'Loading...' }}</h2>
              <div class="flex mb-4">
                <div class="mr-8">
                  <p class="text-3xl font-bold text-blue-500">{{ club?.founded_year || '0' }}+</p>
                  <p class="text-gray-500">Năm phát triển</p>
                </div>
                <div>
                  <p class="text-3xl font-bold text-blue-500">{{ club?.total_events || '0' }}</p>
                  <p class="text-gray-500">Chương trình</p>
                </div>
              </div>
              <div class="flex">
                <div class="mr-8">
                  <p class="text-3xl font-bold text-blue-500">{{ club?.member_count || '0' }}+</p>
                  <p class="text-gray-500">Thành viên</p>
                </div>
                <div>
                  <p class="text-3xl font-bold text-blue-500">{{ club?.advisor_count || '0' }}</p>
                  <p class="text-gray-500">Giảng viên cố vấn</p>
                </div>
              </div>
            </div>

            <!-- Ảnh đại diện -->
            <div class="w-1/2 grid grid-cols-3 gap-4 p-4">
              <img v-for="(image, index) in (club?.background_images || [])" :key="index" :src="image.image_url"
                class="rounded-lg object-cover w-full h-full" alt="Club Image" />
              <!-- Fallback images if not enough club images -->
              <template>
                <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                  <div v-for="(image, index) in displayImages" :key="index"
                    class="aspect-square overflow-hidden rounded-lg">
                    <img :src="image.url || image" :alt="`Club Image ${index + 1}`"
                      class="w-full h-full object-cover rounded-lg" />
                  </div>
                </div>
              </template>
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
                {{ club?.category.name || 'Loading...' }}
              </span>
            </div>
            <p class="text-gray-600 mb-8">
              {{ club?.description || 'Chưa có mô tả' }}
            </p>

          </div>
        </div>
      </section>

      <!-- Past Events -->
      <section class="py-12">
        <div class="container mx-auto px-4">
          <h2 class="text-xl font-semibold mb-6">Sự kiện đã tổ chức</h2>
          <div class="grid md:grid-cols-3 gap-8">
            <div v-for="event in club?.events" :key="event.id" class="bg-white rounded-lg overflow-hidden shadow-lg">
              <img :src="event.background_images?.[0]?.image_url || '../assets/1.webp'" :alt="event.name"
                class="w-full h-48 object-cover" />
              <div class="p-6">
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm text-blue-500">{{ event.status }}</span>
                  <span class="text-sm text-gray-500">{{ event.start_date }}</span>
                </div>
                <h3 class="text-xl font-semibold mt-2 line-clamp-2">{{ event.name }}</h3>
                <p class="text-gray-600 mt-2 line-clamp-3">
                  {{ event.content || 'Chưa có mô tả' }}
                </p>
                <div class="mt-4 flex items-center justify-between">
                  <div class="flex items-center text-sm text-gray-500">
                    <span class="mr-4">
                      <i class="fas fa-map-marker-alt mr-1"></i>
                      {{ event.location }}
                    </span>
                    <span>
                      <i class="fas fa-users mr-1"></i>
                      {{ event.registered_participants }}/{{ event.max_participants }}
                    </span>
                  </div>
                </div>
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

      <section class="py-12 bg-gray-50">
        <div class="container mx-auto px-4">
          <div
            class="max-w-4xl mx-auto grid md:grid-cols-2 gap-8 bg-gradient-to-r bg-gradient-to-b from-blue-600 to-blue-200 rounded-lg p-8 text-white">
            <div>
              <h2 class="text-xl font-semibold mb-4">Gửi phản hồi</h2>
              <p class="mb-4">
                Bạn có thể liên hệ với chúng tôi qua email hoặc số điện thoại sau. Chúng tôi sẽ liên hệ lại bạn trong
                thời gian sớm nhất.
              </p>
              <div class="space-y-2">
                <p>{{ club?.contract_email || 'Chưa có email liên hệ' }}</p>
                <p>{{ club?.contract_phone || 'Chưa có số điện thoại' }}</p>
              </div>
              <div class="mt-4">
                <FacebookIcon class="w-6 h-6" />
              </div>
            </div>

            <form @submit.prevent="handleSubmitFeedback" class="space-y-4 bg-white rounded-lg p-6 shadow-md">
              <div v-if="feedbackStore.isLoading" class="absolute inset-0 bg-white/50 flex items-center justify-center">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
              </div>

              <input v-model="feedbackForm.name" type="text" placeholder="Hãy nhập họ tên" required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500" />

              <input v-model="feedbackForm.mobile" type="tel" placeholder="Hãy nhập số điện thoại" required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500" />

              <input v-model="feedbackForm.email" type="email" placeholder="Hãy nhập email" required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500" />

              <textarea v-model="feedbackForm.comment" rows="4" placeholder="Nội dung" required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-800 placeholder-gray-500"></textarea>

              <div v-if="feedbackStore.error" class="text-red-500 text-sm">
                {{ feedbackStore.error }}
              </div>

              <button type="submit" :disabled="feedbackStore.isLoading"
                class="bg-white border border-gray-300 text-blue-600 px-6 py-2 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed">
                {{ feedbackStore.isLoading ? 'Đang gửi...' : 'Gửi' }}
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
          <button @click="handleJoinRequest"
            :disabled="isJoining || joinStatus === 'request' || joinStatus === 'approved'"
            class="block mx-auto px-8 py-3 rounded-full mb-12 text-lg font-medium transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
            :class="{
              'bg-gradient-to-r from-blue-500 to-blue-600 text-white hover:from-blue-600 hover:to-blue-700': !joinStatus || joinStatus === 'rejected',
              'bg-gradient-to-r from-yellow-400 to-yellow-500 text-white hover:from-yellow-500 hover:to-yellow-600': joinStatus === 'request',
              'bg-gradient-to-r from-green-500 to-green-600 text-white hover:from-green-600 hover:to-green-700': joinStatus === 'approved',
              'opacity-75 cursor-not-allowed transform-none hover:shadow-none': isJoining
            }">
            <div class="flex items-center justify-center gap-2">
              <span v-if="isJoining" class="flex items-center gap-2">
                <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none"
                  viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                  </path>
                </svg>
                Đang xử lý...
              </span>
              <span v-else-if="joinStatus === 'request'" class="flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                Đang chờ duyệt
              </span>
              <span v-else-if="joinStatus === 'approved'" class="flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                Đã là thành viên
              </span>
              <span v-else-if="joinStatus === 'rejected'" class="flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15">
                  </path>
                </svg>
                Đăng ký lại
              </span>
              <span v-else class="flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
                </svg>
                Đăng ký thành viên
              </span>
            </div>
          </button>

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
    </template>
  </div>
</template>

<script setup>

import { ref, onMounted, computed } from 'vue';
import { useClubStore } from "../stores/clubStore";
import { useDepartmentStore } from "../stores/departmentStore";
import { useFeedbackStore } from "../stores/feedbackStore";
import { useRoute, useRouter } from "vue-router";
import { storeToRefs } from 'pinia';
import joinRequestService from '../services/joinRequest';
import Slider from '../components/ClubManage/Slider.vue';
import Comment from '../components/ClubManage/Comment.vue';
const clubStore = useClubStore();
const departmentStore = useDepartmentStore();
const feedbackStore = useFeedbackStore();
const route = useRoute();
const router = useRouter();
const id = route.params.id;

const feedbackForm = ref({
  name: '',
  mobile: '',
  email: '',
  comment: '',
});

const handleSubmitFeedback = async () => {
  try {
    const feedbackData = {
      ...feedbackForm.value,
      club_id: id
    };
    console.log('Gửi phản hồi thành công!', feedbackData);
    await feedbackStore.createFeedback(feedbackData);
    feedbackForm.value = {
      name: '',
      phone: '',
      email: '',
      content: ''
    };
    alert('Cảm ơn bạn đã gửi phản hồi!');
  } catch (error) {
    console.error('Error submitting feedback:', error);
  }
};

// Get reactive state from store
const { selectedClub: club, isLoading: loading, error } = storeToRefs(clubStore);
const { clubDepartments } = storeToRefs(departmentStore);

const isJoining = ref(false);
const joinStatus = ref(null);
const joinError = ref(null);

const isAuthenticated = computed(() => {
  const user = localStorage.getItem('user');
  return !!user;
});

const handleJoinRequest = async () => {
  if (isJoining.value) return;

  if (!isAuthenticated.value) {
    // Lưu current URL để redirect sau khi đăng nhập
    localStorage.setItem('redirectAfterLogin', router.currentRoute.value.fullPath);
    router.push('/login');
    return;
  }

  // Check if user is already a member
  if (joinStatus.value === 'approved') {
    alert('Bạn đã là thành viên của CLB này!');
    return;
  }

  try {
    isJoining.value = true;
    joinError.value = null;

    if (!id) {
      throw new Error('Không tìm thấy thông tin CLB');
    }

    await joinRequestService.createJoinRequest(id);
    joinStatus.value = 'request';
    alert('Đăng ký thành công! Vui lòng chờ phê duyệt.');
  } catch (error) {
    console.error('Error joining club:', error);

    if (error.message === 'Vui lòng đăng nhập để đăng ký tham gia CLB') {
      localStorage.setItem('redirectAfterLogin', router.currentRoute.value.fullPath);
      router.push('/login');
      return;
    }

    joinError.value = error.message || 'Có lỗi xảy ra khi đăng ký. Vui lòng thử lại sau.';
    alert(joinError.value);
  } finally {
    isJoining.value = false;
  }
};

const checkJoinStatus = async () => {
  if (!isAuthenticated.value) {
    joinStatus.value = null;
    return;
  }

  try {
    const response = await joinRequestService.checkClubStatus(id);
    if (response.status === 'approved') {
      joinStatus.value = 'approved';
    } else if (response.status === 'request') {
      joinStatus.value = 'request';
    } else if (response.status === 'rejected') {
      joinStatus.value = 'rejected';
    } else {
      joinStatus.value = null;
    }
  } catch (error) {
    console.error('Error checking join status:', error);
    joinError.value = error.message;
    joinStatus.value = null;
  }
};

const fetchClub = async () => {
  try {
    await clubStore.fetchClubById(id);
  } catch (error) {
    console.error('Error fetching club:', error);
  }
};

onMounted(() => {
  fetchClub();
  checkJoinStatus();
  departmentStore.fetchClubDepartments(id);
});


</script>