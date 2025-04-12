<script setup lang="ts">
import { UserIcon, MailIcon, ListCheckIcon } from 'vue-tabler-icons';
import { useRouter } from 'vue-router';
import authService from '../../../services/authService'; // Đường dẫn đến authService

const router = useRouter();

const handleLogout = () => {
    authService.logout(); // Gọi phương thức logout từ authService
    router.push('/auth/login'); // Chuyển hướng đến trang đăng nhập
};
</script>

<template>
    <!-- ---------------------------------------------- -->
    <!-- notifications DD -->
    <!-- ---------------------------------------------- -->
    <v-menu :close-on-content-click="false">
        <template v-slot:activator="{ props }">
            <v-btn class="profileBtn custom-hover-primary" variant="text" v-bind="props" icon>
                <v-avatar size="35">
                    <img src="@/assets/images/profile/user-1.jpg" height="35" alt="user" />
                </v-avatar>
            </v-btn>
        </template>
        <v-sheet rounded="md" width="200" elevation="10" class="mt-2">
            <div class="pt-4 pb-4 px-5 text-center">
                <v-btn @click="handleLogout" color="primary" variant="outlined" block>Logout</v-btn>
            </div>
        </v-sheet>
    </v-menu>
</template>

<style scoped>
/* Thêm các style nếu cần */
</style>