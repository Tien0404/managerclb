<template>
    <header class="text-white shadow-md bg-white">
    <div class="container mx-auto flex justify-between items-center py-3">
      <!-- Logo -->
      <router-link to="/" class="flex items-center">
        <img src="../assets/vaa.svg" alt="Logo" class="h-10 mr-3" />
        <div>
          <h1 class="font-bold text-lg" style="color: #b3995d">
            HỌC VIỆN HÀNG KHÔNG VIỆT NAM
          </h1>
          <p class="text-sm font-light" style="color: #b3995d">
            VIETNAM AVIATION ACADEMY
          </p>
        </div>
      </router-link>

      <!-- Navigation -->
      <nav class="flex items-center space-x-8">
        <div class="relative group">
          <button class="hover:text-gray-300 flex items-center text-black">
            Câu lạc bộ
            <svg
              class="w-4 h-4 ml-1"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor">
              <path d="M12 16l-6-6h12l-6 6z" />
            </svg>
          </button>
          <!-- Dropdown -->
          <div
            class="absolute left-0 mt-2 bg-white text-black shadow-md rounded hidden group-hover:block w-40">
            <ul>
              <li class="hover:bg-gray-100 px-4 py-2"><a href="#">CLB 1</a></li>
              <li class="hover:bg-gray-100 px-4 py-2"><a href="#">CLB 2</a></li>
            </ul>
          </div>
        </div>
        <router-link to="/event" class="hover:text-gray-300 text-black">
          Sự kiện
        </router-link>
        <router-link to="/blog-list-page" class="hover:text-gray-300 text-black">
          Bài viết
        </router-link>
      </nav>

      <!-- User Actions -->
      <div class="flex items-center space-x-4">
        <router-link v-if="isLoggedIn" to="/manage-club-page">
          <button class="flex items-center bg-white border-solid border-2 px-4 py-2 rounded hover:bg-gray-200 text-black">
            Quản lý CLB
          </button>
        </router-link>
        <div class="relative">
          <button class="relative" @click="toggleNotifications">
            <svg
              class="w-6 h-6 text-black hover:text-gray-300"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor">
              <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z"/>
            </svg>
            <span v-if="unreadNotifications" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">{{ unreadNotifications }}</span>
          </button>

          <!-- Notification Panel -->
          <div v-if="showNotifications" class="absolute top-8 right-0 w-96 bg-white shadow-lg rounded-lg border overflow-hidden z-50">
            <div class="flex justify-between items-center p-4 border-b">
              <h2 class="font-semibold text-black">Thông báo</h2>
              <router-link to="/notifications" class="text-blue-600 text-sm hover:underline">
                Tất cả thông báo
              </router-link>
            </div>

            <div class="divide-y max-h-96 overflow-y-auto">
              <div v-for="notification in notifications" :key="notification.id" class="p-4 flex gap-3 hover:bg-gray-50">
                <div class="w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center bg-blue-100">
                  <img
                    :src="notification.icon || '/placeholder.svg'"
                    :alt="notification.title"
                    class="w-8 h-8 object-cover rounded-full"
                  />
                </div>
                <div class="flex-1">
                  <div class="text-xs text-black">{{ notification.date }}</div>
                  <p class="text-sm text-black">{{ notification.message }}</p>
                  <div v-if="notification.type === 'info'" class="mt-2 flex gap-2">
                    <button @click="handleInviteResponse(notification.id, 'approved')" class="px-3 py-1 bg-green-500 text-white rounded-md text-sm hover:bg-green-600">
                      Chấp nhận
                    </button>
                    <button @click="handleInviteResponse(notification.id, 'rejected')" class="px-3 py-1 bg-red-500 text-white rounded-md text-sm hover:bg-red-600">
                      Từ chối
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="p-3 border-t">
              <button @click="markAllAsRead" class="w-full py-2 flex items-center justify-center gap-2 text-sm text-black border rounded-md hover:bg-gray-50">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
                Đã đọc tất cả
              </button>
            </div>
          </div>
        </div>
        <DropDownMenu :options="dropdownOptions" @select="handleSelect">
          <template #trigger>
            <img
              :src="userAvatar"
              :alt="isLoggedIn ? 'User Avatar' : 'Default Avatar'"
              class="w-8 h-8 hover:opacity-75 rounded-full object-cover" />
          </template>
        </DropDownMenu>
      </div>
    </div>
    <div>
  </div>
  </header>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue';
import Image1 from "../assets/avatar.jpg";
import DropDownMenu from "../components/DropDownMenu.vue";
import { UserRoundPen, LogOut, User } from "lucide-vue-next";
import { useAuthStore } from '../stores/authStore';
import { useJoinRequestStore } from '../stores/joinRequestStore';
import { useRouter } from 'vue-router';

export default {
  name: "HeaderComponent",
  components: {
    DropDownMenu,
  },
  setup() {
    const authStore = useAuthStore();
    const joinRequestStore = useJoinRequestStore();
    const router = useRouter();
    const showNotifications = ref(false);
    const unreadNotifications = ref(0);
    const notifications = ref([
      
    ]);
    
    // Khởi tạo store và fetch thông báo khi component được mount
    onMounted(async () => {
      authStore.initializeStore();
      if (authStore.isAuthenticated) {
        await joinRequestStore.fetchUserRequests();
      }
      // Thêm sự kiện click outside để đóng panel thông báo
      document.addEventListener('click', (e) => {
        const notificationPanel = document.querySelector('.notification-panel');
        if (notificationPanel && !notificationPanel.contains(e.target) && showNotifications.value) {
          showNotifications.value = false;
        }
      });
    });

    // Hàm cắt chuỗi và thêm dấu chấm lửng
    const truncateText = (text, maxLength = 30) => {
      if (!text) return '';
      return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
    };

    // Theo dõi thay đổi của joinRequests để cập nhật notifications
    watch(() => joinRequestStore.joinRequests, (newRequests) => {
      console.log('Dữ liệu join requests gốc:', newRequests);
      if (newRequests && newRequests.length > 0) {
        const filteredRequests = newRequests
          .filter(request => request.status === 'approved' || request.status === 'rejected' || request.status === 'invite')
          .sort((a, b) => new Date(b.responded_at) - new Date(a.responded_at));
        console.log('Dữ liệu join requests sau khi lọc và sắp xếp:', filteredRequests);
        notifications.value = filteredRequests
          .map(request => ({
            id: request.id,
            type: request.status === 'approved' ? 'success' : request.status === 'invite' ? 'info' : 'error',
            icon: request.club_id
              ? (request.club?.background_images?.find(img => img.is_logo)?.image_url || '/placeholder.svg')
              : (request.event?.background_images?.find(img => img.is_logo)?.image_url || '/placeholder.svg'),
            date: new Date(request.responded_at).toLocaleDateString('vi-VN'),
            message: request.message || 
              (request.status === 'invite' && request.club_id ? 
                `Bạn được mời tham gia ${truncateText(request.club?.name || 'CLB')}` :
                (request.club_id ? 
                  `Yêu cầu tham gia ${truncateText(request.club?.name || 'CLB')} đã ${request.status === 'approved' ? 'được chấp nhận' : 'bị từ chối'}` : 
                  request.event_id ? 
                    `Yêu cầu tham gia sự kiện ${truncateText(request.event?.name || '')} đã ${request.status === 'approved' ? 'được chấp nhận' : 'bị từ chối'}` : 
                    `Yêu cầu của bạn đã ${request.status === 'approved' ? 'được chấp nhận' : 'bị từ chối'}`)),
            read: false
          }));
        console.log('Dữ liệu notifications sau khi chuyển đổi:', notifications.value);
        unreadNotifications.value = notifications.value.filter(n => !n.read).length;
      }
    }, { immediate: true });
    
    const userAvatar = computed(() => {
      return authStore.userAvatar || Image1;
    });

    const isLoggedIn = computed(() => {
      return authStore.isAuthenticated;
    });

    const toggleNotifications = () => {
      showNotifications.value = !showNotifications.value;
    };

    const markAllAsRead = () => {
      notifications.value.forEach(notification => notification.read = true);
      unreadNotifications.value = 0;
    };

    const handleInviteResponse = async (requestId, status) => {
      try {
        const response_message = status === 'approved' 
          ? 'Cảm ơn bạn đã chấp nhận lời mời tham gia câu lạc bộ của chúng tôi!' 
          : 'Cảm ơn bạn đã phản hồi. Chúng tôi rất tiếc vì quyết định của bạn.';
        await joinRequestStore.updateJoinRequest(requestId, { status, response_message });
        // Cập nhật lại danh sách thông báo sau khi xử lý
        await joinRequestStore.fetchUserRequests();
      } catch (error) {
        console.error('Lỗi khi cập nhật trạng thái:', error);
      }
    };
    
    return { 
      authStore, 
      router, 
      userAvatar, 
      isLoggedIn, 
      showNotifications,
      unreadNotifications,
      notifications,
      toggleNotifications,
      markAllAsRead,
      handleInviteResponse
    };
  },
  data() {
    return {
      Image1,
      dropdownOptions: [],
    };
  },
  watch: {
    isLoggedIn: {
      immediate: true,
      handler(newValue) {
        this.updateDropdownOptions(newValue);
      },
    },
  },
  methods: {
    updateDropdownOptions(isLoggedIn) {
      if (isLoggedIn) {
        this.dropdownOptions = [
          { label: "Trang Cá Nhân", icon: UserRoundPen },
          { label: "Đăng Xuất", icon: LogOut },
        ];
      } else {
        this.dropdownOptions = [{ label: "Đăng Nhập", icon: User }];
      }
    },
    async handleSelect(option) {
      if (option.label === "Trang Cá Nhân") {
        this.$router.push("/profile");
      } else if (option.label === "Đăng Xuất") {
        try {
          await this.authStore.logout();
          await this.$router.push("/login");
          window.location.reload();
        } catch (error) {
          console.error('Lỗi khi đăng xuất:', error);
        }
      } else if (option.label === "Đăng Nhập") {
        this.$router.push("/login");
      }
    },
  },
};
</script>

