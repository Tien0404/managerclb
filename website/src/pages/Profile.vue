<template>
  <div v-if="!isAuth" class="min-h-screen flex items-center justify-center">
    <div class="text-center">
      <h2 class="text-2xl font-bold mb-4">Vui lòng đăng nhập để xem thông tin cá nhân</h2>
      <router-link 
        to="/login" 
        class="inline-block px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
      >
        Đăng nhập
      </router-link>
    </div>
  </div>
  <Infomation v-else />
</template>

<script setup>
import Infomation from "../components/Profile/Infomation.vue";
import { computed, onMounted } from 'vue';
import { useAuthStore } from '../stores/authStore';
import { useRouter } from 'vue-router';

const router = useRouter();
const authStore = useAuthStore();

const isAuth = computed(() => authStore.isAuthenticated);

// Khởi tạo store và lấy thông tin user khi component được mount
onMounted(async () => {
  authStore.initializeStore();
  if (!authStore.isAuthenticated) {
    router.push('/login');
    return;
  }
  try {
    await authStore.fetchUserInfo();
  } catch (error) {
    console.error('Lỗi khi lấy thông tin user:', error);
  }
});
</script>
