<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading State -->
    <div v-if="eventStore.isLoading" class="flex justify-center items-center min-h-screen">
      <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="eventStore.error" class="flex justify-center items-center min-h-screen">
      <div class="text-center">
        <p class="text-red-500 text-xl mb-4">{{ eventStore.error }}</p>
        <button @click="fetchEvent" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
          Thử lại
        </button>
      </div>
    </div>

    <!-- Content when data is loaded -->
    <main v-else class="max-w-7xl mx-auto px-4 py-8">
      <div class="bg-white rounded-lg shadow-lg overflow-hidden">
        <div class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="md:col-span-2 space-y-6">
              <section>
                <h2 class="text-2xl font-bold mb-4">
                  {{ event?.name }}
                </h2>
                <div class="flex items-center space-x-4">
                  <div class="relative w-16 h-16">
                    <div v-if="clubLogo.loading"
                      class="absolute inset-0 flex items-center justify-center bg-gray-100 rounded-full">
                      <div class="animate-spin h-6 w-6 border-2 border-blue-500 rounded-full border-t-transparent">
                      </div>
                    </div>
                    <img v-if="clubLogo.url" :src="clubLogo.url" alt="Club Logo"
                      class="h-16 w-16 rounded-full object-cover transition-opacity duration-300"
                      :class="{ 'opacity-0': clubLogo.loading }" @load="handleImageLoad('clubLogo')"
                      @error="handleImageError('clubLogo')" />
                  </div>
                  <div>
                    <h3 class="text-lg font-semibold">
                      {{ event?.club?.name }}
                    </h3>
                    <p class="text-gray-600">Đơn vị tổ chức</p>
                  </div>
                </div>
              </section>
              <section>
                <h2 class="text-2xl font-bold mb-4">Nội dung chi tiết</h2>
                <div class="prose max-w-none">
                  {{ event?.content || 'Chưa có nội dung chi tiết' }}
                </div>
              </section>
            </div>

            <div class="space-y-6">
              <div class="relative h-80">
                <div class="relative w-full h-full">
                  <div v-if="eventImage.loading"
                    class="absolute inset-0 flex items-center justify-center bg-gray-100 rounded-lg">
                    <div class="animate-spin h-8 w-8 border-2 border-blue-500 rounded-full border-t-transparent"></div>
                  </div>
                  <img v-if="eventImage.url" :src="eventImage.url" :alt="event?.name"
                    class="w-full h-full object-cover rounded-lg transition-opacity duration-300"
                    :class="{ 'opacity-0': eventImage.loading }" @load="handleImageLoad('eventImage')"
                    @error="handleImageError('eventImage')" />
                </div>
                <div class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center rounded-lg">
                  <div class="text-center text-white p-4">
                    <span class="inline-block px-3 py-1 bg-blue-500 text-white rounded-full text-sm mb-4">
                      {{ event?.status }}
                    </span>
                    <h1 class="text-2xl font-bold mb-2">
                      {{ event?.name }}
                    </h1>
                    <p class="text-lg">{{ event?.club?.name }}</p>
                  </div>
                </div>
              </div>

              <div class="bg-gray-50 p-6 rounded-lg space-y-4">
                <h3 class="text-lg font-semibold mb-4">Thông tin Event</h3>
                <div class="space-y-4">
                  <div class="flex items-start space-x-3">
                    <ClockIcon class="h-5 w-5 text-gray-500 mt-0.5" />
                    <div>
                      <h4 class="font-medium">Ngày bắt đầu</h4>
                      <p class="text-gray-600">{{ formatDate(event?.start_date) }}</p>
                    </div>
                  </div>
                  <div class="flex items-start space-x-3">
                    <ClockIcon class="h-5 w-5 text-gray-500 mt-0.5" />
                    <div>
                      <h4 class="font-medium">Ngày kết thúc</h4>
                      <p class="text-gray-600">{{ formatDate(event?.end_date) }}</p>
                    </div>
                  </div>
                  <div class="flex items-start space-x-3">
                    <MapPinIcon class="h-5 w-5 text-gray-500 mt-0.5" />
                    <div>
                      <h4 class="font-medium">Địa điểm</h4>
                      <p class="text-gray-600">{{ event?.location }}</p>
                    </div>
                  </div>
                  <div class="flex items-start space-x-3">
                    <UsersIcon class="h-5 w-5 text-gray-500 mt-0.5" />
                    <div>
                      <h4 class="font-medium">Số lượng tham gia</h4>
                      <p class="text-gray-600">{{ event?.registered_participants }}/{{ event?.max_participants }} người
                        đăng ký</p>
                    </div>
                  </div>
                </div>

                <button @click="handleRegistration"
                  :disabled="isJoining || registrationStatus === 'request' || registrationStatus === 'approved' || isEventFull || isEventExpired"
                  class="w-full py-3 px-6 rounded-full text-lg font-medium transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-1 disabled:transform-none disabled:hover:shadow-none"
                  :class="{
                    'bg-gradient-to-r from-blue-500 to-blue-600 text-white hover:from-blue-600 hover:to-blue-700': !registrationStatus || registrationStatus === 'rejected',
                    'bg-gradient-to-r from-yellow-400 to-yellow-500 text-white hover:from-yellow-500 hover:to-yellow-600': registrationStatus === 'request',
                    'bg-gradient-to-r from-green-500 to-green-600 text-white hover:from-green-600 hover:to-green-700': registrationStatus === 'approved',
                    'bg-gray-400 text-white cursor-not-allowed': isEventFull || isEventExpired,
                    'opacity-75 cursor-not-allowed': isJoining
                  }">
                  <div class="flex items-center justify-center gap-2">
                    <span v-if="isJoining" class="flex items-center gap-2">
                      <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none"
                        viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
                        </circle>
                        <path class="opacity-75" fill="currentColor"
                          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                        </path>
                      </svg>
                      Đang xử lý...
                    </span>
                    <span v-else-if="isEventExpired" class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                      Sự kiện đã kết thúc
                    </span>
                    <span v-else-if="isEventFull" class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                      </svg>
                      Sự kiện đã đủ người
                    </span>
                    <span v-else-if="registrationStatus === 'request'" class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                      Đăng ký thành công
                    </span>
                    <span v-else-if="registrationStatus === 'approved'" class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                      </svg>
                      Đã tham gia sự kiện
                    </span>
                    <span v-else-if="registrationStatus === 'rejected'" class="flex items-center gap-2">
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
                          d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                      </svg>
                      Đăng ký tham gia
                    </span>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import Image1 from '../assets/1.webp';
import { MapPinIcon, PhoneIcon, MailIcon, ClockIcon, UsersIcon } from "lucide-vue-next";
import { ref, onMounted, computed, watch, onUnmounted } from 'vue';
import { useEventStore } from "../stores/eventStore";
import { useRoute, useRouter } from "vue-router";
import { storeToRefs } from 'pinia';
import { useJoinRequestStore } from "../stores/joinRequestStore";

const eventStore = useEventStore();
const joinRequestStore = useJoinRequestStore();
const route = useRoute();
const router = useRouter();
const id = computed(() => route.params.id);

// Reactive references for images with loading states
const clubLogo = ref({ url: null, loading: false, error: false });
const eventImage = ref({ url: null, loading: false, error: false });
const event = computed(() => eventStore.selectedEvent);

// Thêm state cho trạng thái đăng ký
const registrationStatus = ref(null);
const isJoining = ref(false);
const pollingInterval = ref(null);

// Handle image loading states
const handleImageLoad = (type) => {
  if (type === 'clubLogo') {
    clubLogo.value.loading = false;
  } else if (type === 'eventImage') {
    eventImage.value.loading = false;
  }
};

const handleImageError = (type) => {
  if (type === 'clubLogo') {
    clubLogo.value.error = true;
    clubLogo.value.loading = false;
    clubLogo.value.url = Image1;
  } else if (type === 'eventImage') {
    eventImage.value.error = true;
    eventImage.value.loading = false;
    eventImage.value.url = Image1;
  }
};

// Format date with memoization
const dateFormatter = new Intl.DateTimeFormat('vi-VN', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit'
});

const formatDate = (dateString) => {
  if (!dateString) return 'Chưa cập nhật';
  return dateFormatter.format(new Date(dateString));
};

// Watch for event changes to update images
watch(() => event.value, (newEvent) => {
  if (newEvent) {
    // Update club logo
    if (newEvent.club?.background_images?.[0]?.image_url) {
      clubLogo.value = {
        url: newEvent.club.background_images[0].image_url,
        loading: true,
        error: false
      };
    }

    // Update event image
    if (newEvent.background_images?.[0]?.image_url) {
      eventImage.value = {
        url: newEvent.background_images[0].image_url,
        loading: true,
        error: false
      };
    }
  }
}, { immediate: true });

const fetchEvent = async () => {
  try {
    await eventStore.fetchEventById(id.value);
  } catch (error) {
    console.error('Error fetching event:', error);
  }
};

// Hàm kiểm tra trạng thái đăng ký
const checkRegistrationStatus = async (forceRefresh = false) => {
  try {
    const response = await joinRequestStore.checkEventStatus(id.value);
    registrationStatus.value = response.status;

    // Nếu đang chờ duyệt, tiếp tục polling
    if (response.status === 'request' && !pollingInterval.value) {
      startPolling();
    } else if (response.status !== 'request' && pollingInterval.value) {
      stopPolling();
    }
  } catch (error) {
    console.error('Error checking registration status:', error);
    registrationStatus.value = null;
  }
};

// Hàm bắt đầu polling
const startPolling = () => {
  pollingInterval.value = setInterval(() => {
    checkRegistrationStatus(true); // Force refresh khi polling
  }, 30000); // Poll mỗi 30 giây
};

// Hàm dừng polling
const stopPolling = () => {
  if (pollingInterval.value) {
    clearInterval(pollingInterval.value);
    pollingInterval.value = null;
  }
};

// Cập nhật hàm handleRegistration
const handleRegistration = async () => {
  if (isJoining.value) return;

  try {
    isJoining.value = true;

    // Kiểm tra đăng nhập
    const user = JSON.parse(localStorage.getItem('user'));
    if (!user) {
      localStorage.setItem('redirectAfterLogin', router.currentRoute.value.fullPath);
      router.push('/login');
      return;
    }

    // Tạo yêu cầu đăng ký
    await joinRequestStore.createJoinRequest(null, id.value);
    registrationStatus.value = 'approved';
    alert('Đăng ký tham gia sự kiện thành công!');
  } catch (error) {
    console.error('Error registering for event:', error);
    alert(error.message);
  } finally {
    isJoining.value = false;
  }
};

// Add this computed property after the other computed properties
const isEventFull = computed(() => {
  return event.value?.registered_participants >= event.value?.max_participants;
});

// Add this computed property after isEventFull
const isEventExpired = computed(() => {
  if (!event.value?.end_date) return false;
  return new Date(event.value.end_date) < new Date();
});

onMounted(() => {
  fetchEvent();
  checkRegistrationStatus();
});

// Cleanup
onUnmounted(() => {
  stopPolling();
});
</script>

<style>
.prose {
  @apply text-gray-600 leading-relaxed;
}

.prose p {
  @apply mb-4;
}

img {
  object-fit: cover;
}

/* Add image loading animation */
img {
  transition: opacity 0.3s ease-in-out;
}

img[src] {
  opacity: 1;
}

img:not([src]) {
  opacity: 0;
}

/* Add hover effects */
button {
  transition: all 0.2s ease-in-out;
}

button:hover {
  transform: translateY(-1px);
}

button:active {
  transform: translateY(0);
}
</style>