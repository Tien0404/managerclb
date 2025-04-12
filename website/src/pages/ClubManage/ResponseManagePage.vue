<template>
  <div class="min-h-screen bg-white" :class="{ 'opacity-50 pointer-events-none': !departmentStore.canManageFeedback }">
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <!-- Header -->
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-blue-500">Quản lý phản hồi</h1>
        <div class="flex gap-2">
          <button 
            @click="filterResponses('all')"
            class="flex items-center gap-1 text-gray-600 border rounded-lg px-4 py-2 hover:bg-gray-50"
            :class="{'bg-blue-50': currentFilter === 'all'}"
          >
            Tất cả
          </button>
          <button 
            @click="filterResponses('pending')"
            class="flex items-center gap-1 text-gray-600 border rounded-lg px-4 py-2 hover:bg-gray-50"
            :class="{'bg-yellow-50': currentFilter === 'pending'}"
          >
            Chờ xử lý
          </button>
        </div>
      </div>

      <!-- Response Content -->
      <div class="border rounded-lg overflow-hidden">
        <div class="grid md:grid-cols-[40%_60%]">
          <!-- Left sidebar - Response list -->
          <div class="border-r">
            <div 
              v-for="response in filteredResponses" 
              :key="response.id"
              class="flex gap-3 p-4 cursor-pointer hover:bg-gray-50 border-b"
              :class="{
                'bg-gray-50 border-l-4 border-l-blue-500': selectedResponse === response.id,
                'border-l-4 border-l-green-500': response.status === 'resolved',
                'border-l-4 border-l-yellow-500': response.status === 'pending'
              }"
              @click="selectResponse(response.id)"
            >
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-full flex items-center justify-center overflow-hidden bg-blue-100">
                  <img 
                    :src="response.user?.avatar || avatarDefault"
                    :alt="response.user?.name"
                    class="w-full h-full object-cover"
                  />
                </div>
              </div>
              <div class="flex-1">
                <div class="text-gray-500 text-sm">{{ response.date }}</div>
                <p class="text-gray-800 font-medium">{{ response.name }}</p>
                <p class="text-gray-600 text-sm">{{ response.comment }}</p>
                <div class="mt-1 text-xs text-gray-500">
                  <span>{{ response.email }}</span>
                  <span class="mx-1">•</span>
                  <span>{{ response.mobile }}</span>
                </div>
              </div>
              <div v-if="response.status === 'pending'" class="flex-shrink-0">
                <span class="inline-block w-2 h-2 rounded-full bg-yellow-400"></span>
              </div>
            </div>

            <div v-if="!filteredResponses.length" class="p-8 text-center text-gray-500">
              Không có phản hồi nào
            </div>
          </div>

          <!-- Right content - Response detail -->
          <div class="p-6" v-if="selectedResponseDetail">
            <div class="flex items-start justify-between mb-6">
              <div class="flex gap-4">
                <div class="w-12 h-12 rounded-full flex items-center justify-center overflow-hidden bg-blue-100">
                  <img 
                    :src="selectedResponseDetail.user?.avatar || avatarDefault"
                    :alt="selectedResponseDetail.name"
                    class="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <h2 class="text-xl font-semibold">{{ selectedResponseDetail.name }}</h2>
                  <div class="flex items-center gap-2 text-gray-500 text-sm mt-1">
                    <span>{{ selectedResponseDetail.date }}</span>
                    <span>•</span>
                    <span>{{ selectedResponseDetail.email }}</span>
                    <span>•</span>
                    <span>{{ selectedResponseDetail.mobile }}</span>
                  </div>
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <span 
                  :class="{
                    'bg-green-200 text-green-800': selectedResponseDetail.status === 'resolved',
                    'bg-yellow-200 text-yellow-800': selectedResponseDetail.status === 'pending',
                  }"
                  class="px-3 py-1 rounded-md text-sm min-w-[100px] inline-block text-center whitespace-nowrap"
                >
                  {{ 
                    selectedResponseDetail.status === 'resolved' ? 'Đã chấp nhận' : 
                    selectedResponseDetail.status === 'pending' ? 'Chờ xử lý' : 'Đã từ chối' 
                  }}
                </span>
              </div>
            </div>

            <div class="border-t pt-6">
              <div class="mb-6">
                <h3 class="font-medium text-gray-700 mb-2">Nội dung yêu cầu</h3>
                <p class="text-gray-800">{{ selectedResponseDetail.comment }}</p>
              </div>

              <div v-if="selectedResponseDetail.club_response" class="mb-6">
                <h3 class="font-medium text-gray-700 mb-2">Phản hồi từ câu lạc bộ</h3>
                <p class="text-gray-800">{{ selectedResponseDetail.club_response }}</p>
              </div>

              <div class="mb-6" v-if="selectedResponseDetail.status !== 'resolved'">
                <h3 class="font-medium text-gray-700 mb-2">Phản hồi</h3>
                <textarea
                  v-model="responseMessage"
                  class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  rows="4"
                  placeholder="Nhập phản hồi của bạn..."
                ></textarea>
                <button 
                  @click="handleResponse(selectedResponseDetail.id)"
                  class="mt-3 px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
                  :disabled="!departmentStore.canManageFeedback"
                >
                  Gửi phản hồi
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useFeedbackStore } from '../../stores/feedbackStore';
import { useDepartmentStore } from '../../stores/departmentStore';
import avatarDefault from '../../assets/avatar.jpg';

const route = useRoute();
const feedbackStore = useFeedbackStore();
const departmentStore = useDepartmentStore();
const responses = ref([]);
const selectedResponse = ref(null);
const currentFilter = ref('all');
const responseMessage = ref('');

// Computed property for selected response details
const selectedResponseDetail = computed(() => {
  return responses.value.find(r => r.id === selectedResponse.value);
});

// Computed property for filtered responses
const filteredResponses = computed(() => {
  if (currentFilter.value === 'all') return responses.value;
  return responses.value.filter(response => response.status === 'pending');
});

// Function to select a response
const selectResponse = (id) => {
  selectedResponse.value = id;
};

// Function to filter responses
const filterResponses = (filter) => {
  currentFilter.value = filter;
};

// Handle response action
const handleResponse = async (feedbackId) => {
  try {
    if (!responseMessage.value.trim()) {
      alert('Vui lòng nhập nội dung phản hồi');
      return;
    }
    await feedbackStore.updateFeedback(feedbackId, { club_response: responseMessage.value });
    responseMessage.value = '';
    await fetchResponses(); // Refresh the list after update
  } catch (error) {
    console.error('Lỗi khi gửi phản hồi:', error);
  }
};

// Fetch responses from the store
const fetchResponses = async () => {
  const clubId = route.params.id;
  await feedbackStore.fetchClubFeedbacks(clubId);
  
  console.log('Dữ liệu feedback từ store:', feedbackStore.clubFeedbacks);
  
  if (feedbackStore.clubFeedbacks?.length > 0) {
    const allFeedbacks = feedbackStore.clubFeedbacks.map(feedback => ({
        id: feedback.id,
        club_id: feedback.club_id,
        name: feedback.name,
        email: feedback.email,
        mobile: feedback.mobile,
        comment: feedback.comment || 'Không có nội dung phản hồi',
        status: feedback.status || 'pending',
        date: new Date(feedback.created_at).toLocaleDateString('vi-VN'),
        club_response: feedback.club_response || null,
        club: {
            id: feedback.club?.id,
            name: feedback.club?.name
        }
    }));
    console.log('Dữ liệu feedback sau khi xử lý:', allFeedbacks);

    // Filter responses based on currentFilter
    responses.value = currentFilter.value === 'pending'
      ? allFeedbacks.filter(feedback => feedback.status === 'pending')
      : allFeedbacks;

    // Select first response by default if none selected
    if (!selectedResponse.value && responses.value.length > 0) {
      selectedResponse.value = responses.value[0].id;
    }
  }
};

// Fetch responses on component mount
onMounted(async () => {
  await fetchResponses();
});
</script>