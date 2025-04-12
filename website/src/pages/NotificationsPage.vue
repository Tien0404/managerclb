<template>
  <div class="min-h-screen bg-white">
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <!-- Header -->
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-blue-500">Thông báo của tôi</h1>
        <button 
          @click="markAllAsRead" 
          class="flex items-center gap-1 text-gray-600 border rounded-lg px-4 py-2 hover:bg-gray-50"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-check">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
          Đã đọc tất cả
        </button>
      </div>

      <!-- Notification Content -->
      <div class="border rounded-lg overflow-hidden">
        <div class="grid md:grid-cols-[40%_60%]">
          <!-- Left sidebar - Notification list -->
          <div class="border-r">
            <div 
              v-for="notification in notifications" 
              :key="notification.id"
              class="flex gap-3 p-4 cursor-pointer hover:bg-gray-50 border-b"
              :class="{
                'bg-gray-50 border-l-4 border-l-blue-500': selectedNotification === notification.id,
                'border-l-4 border-l-green-500': notification.status === 'approved',
                'border-l-4 border-l-red-500': notification.status === 'rejected'
              }"
              @click="selectNotification(notification.id)"
            >
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-full flex items-center justify-center overflow-hidden"
                     :class="notification.club_id ? 'bg-blue-100' : 'bg-red-100'">
                  <img 
                    :src="notification.icon || '/placeholder.svg'"
                    :alt="notification.message"
                    class="w-full h-full object-cover"
                  />
                </div>
              </div>
              <div>
                <div class="text-gray-500 text-sm">{{ notification.date }}</div>
                <p class="text-gray-800">{{ notification.message }}</p>
              </div>
            </div>

            <div v-if="!notifications.length" class="p-8 text-center text-gray-500">
              Không có thông báo nào
            </div>
          </div>

          <!-- Right content - Notification detail -->
          <div class="p-6" v-if="selectedNotificationDetail">
            <div class="flex items-start justify-between mb-6">
              <div class="flex gap-4">
                <div class="w-12 h-12 rounded-full flex items-center justify-center overflow-hidden"
                     :class="selectedNotificationDetail.club_id ? 'bg-blue-100' : 'bg-red-100'">
                  <img 
                    :src="selectedNotificationDetail.icon || '/placeholder.svg'"
                    :alt="selectedNotificationDetail.message"
                    class="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <h2 class="text-xl font-semibold">{{ selectedNotificationDetail.message }}</h2>
                  <div class="flex items-center gap-2 text-gray-500 text-sm mt-1">
                    <span>{{ selectedNotificationDetail.date }}</span>
                  </div>
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <span 
                  :class="{
                    'bg-purple-200 text-purple-800': selectedNotificationDetail.club_id,
                    'bg-red-200 text-red-800': !selectedNotificationDetail.club_id
                  }"
                  class="px-3 py-1 rounded-md text-sm min-w-[100px] inline-block text-center whitespace-nowrap"
                >
                  {{ selectedNotificationDetail.club_id ? 'Câu lạc bộ' : 'Sự kiện' }}
                </span>
                <span 
                  :class="{
                    'bg-green-200 text-green-800': selectedNotificationDetail.status === 'approved',
                    'bg-yellow-200 text-yellow-800': selectedNotificationDetail.status === 'invite',
                    'bg-red-200 text-red-800': selectedNotificationDetail.status === 'rejected'
                  }"
                  class="px-3 py-1 rounded-md text-sm min-w-[100px] inline-block text-center whitespace-nowrap"
                >
                  {{ 
                    selectedNotificationDetail.status === 'approved' ? 'Đã chấp nhận' : 
                    selectedNotificationDetail.status === 'invite' ? 'Lời mời' : 'Đã từ chối' 
                  }}
                </span>
              </div>
            </div>

            <div class="border-t pt-6">
              <p class="text-gray-800 mb-2">
                {{ selectedNotificationDetail.message }}
              </p>
              <p v-if="selectedNotificationDetail.response_message" class="text-gray-600 text-sm mb-6 italic">
                {{ selectedNotificationDetail.response_message }}
              </p>
              
              <!-- Nút chấp nhận/từ chối cho thông báo mời -->
              <div v-if="selectedNotificationDetail.status === 'invite'" class="flex gap-2 mb-4">
                <button 
                  @click="handleInviteResponse(selectedNotificationDetail.id, 'approved')"
                  class="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600"
                >
                  Chấp nhận
                </button>
                <button 
                  @click="handleInviteResponse(selectedNotificationDetail.id, 'rejected')"
                  class="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600"
                >
                  Từ chối
                </button>
              </div>

              <router-link 
                :to="{
                  path: selectedNotificationDetail.club_id ? `/clb/${selectedNotificationDetail.club_id}` : `/event/${selectedNotificationDetail.event_id}`
                }"
                class="border rounded-md px-4 py-2 hover:bg-gray-50 text-gray-800 inline-block"
              >
                {{ selectedNotificationDetail.club_id ? 'Xem CLB' : 'Xem sự kiện' }}
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useJoinRequestStore } from '../stores/joinRequestStore';

const joinRequestStore = useJoinRequestStore();
const notifications = ref([]);
const selectedNotification = ref(null);

// Computed property for selected notification details
const selectedNotificationDetail = computed(() => {
  return notifications.value.find(n => n.id === selectedNotification.value);
});

// Function to select a notification
const selectNotification = (id) => {
  selectedNotification.value = id;
};

// Hàm cắt chuỗi và thêm dấu chấm lửng
const truncateText = (text, maxLength = 30) => {
  if (!text) return '';
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
};

const markAllAsRead = async () => {
  notifications.value.forEach(notification => notification.read = true);
};

// Xử lý phản hồi lời mời
const handleInviteResponse = async (requestId, status) => {
  try {
    const response_message = status === 'approved' 
      ? 'Cảm ơn bạn đã chấp nhận lời mời tham gia câu lạc bộ của chúng tôi!' 
      : 'Cảm ơn bạn đã phản hồi. Chúng tôi rất tiếc vì quyết định của bạn.';
    await joinRequestStore.updateJoinRequest(requestId, { status, response_message });
    await joinRequestStore.fetchUserRequests();
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái:', error);
  }
};

// Fetch notifications on component mount
onMounted(async () => {
  await joinRequestStore.fetchUserRequests();
  
  if (joinRequestStore.joinRequests?.length > 0) {
    const filteredRequests = joinRequestStore.joinRequests
      .filter(request => ['approved', 'rejected', 'invite'].includes(request.status))
      .sort((a, b) => new Date(b.responded_at || b.created_at) - new Date(a.responded_at || a.created_at));

    notifications.value = filteredRequests.map(request => ({
      id: request.id,
      type: request.status === 'approved' ? 'success' : request.status === 'invite' ? 'info' : 'error',
      icon: request.club_id
        ? (request.club?.background_images?.find(img => img.is_logo)?.image_url || '/placeholder.svg')
        : (request.event?.background_images?.find(img => img.is_logo)?.image_url || '/placeholder.svg'),
      date: new Date(request.responded_at || request.created_at).toLocaleDateString('vi-VN'),
      message: request.message || 
        (request.status === 'invite' && request.club_id ? 
          `Bạn được mời tham gia ${truncateText(request.club?.name || 'CLB')}` :
          (request.club_id ? 
            `Yêu cầu tham gia ${truncateText(request.club?.name || 'CLB')} đã ${request.status === 'approved' ? 'được chấp nhận' : 'bị từ chối'}` : 
            request.event_id ? 
              `Yêu cầu tham gia sự kiện ${truncateText(request.event?.name || '')} đã ${request.status === 'approved' ? 'được chấp nhận' : 'bị từ chối'}` : 
              `Yêu cầu của bạn đã ${request.status === 'approved' ? 'được chấp nhận' : 'bị từ chối'}`)),
      club_id: request.club_id,
      event_id: request.event_id,
      status: request.status,
      read: false
    }));

    // Select first notification by default
    if (notifications.value.length > 0) {
      selectedNotification.value = notifications.value[0].id;
    }
  }
});
</script>