<script setup lang="ts">
import { ref } from 'vue';
import Logo from '@/layouts/full/logo/Logo.vue';
import authService from '../../services/authService'; // Đường dẫn đến authService
import { useRouter } from 'vue-router';

const email = ref('');
const password = ref('');
const error = ref('');
const router = useRouter();

const handleLogin = async () => {
    error.value = ''; // Reset lỗi trước khi gọi API
    try {
        const credentials = { email: email.value, password: password.value };
        const response = await authService.login(credentials); // Gọi API để đăng nhập
        console.log('Login Response:', response);
        // Chuyển hướng đến trang chính nếu đăng nhập thành công
        if (response && response.access_token) {
            router.push('/'); // Chuyển hướng đến trang chính
        } else {
            error.value = 'Đăng nhập không thành công. Vui lòng kiểm tra lại.'; // Hiển thị lỗi nếu không thành công
        }
    } catch (err) {
        error.value = 'Đăng nhập không thành công. Vui lòng kiểm tra lại.'; // Hiển thị lỗi
    }
};
</script>

<template>
    <div class="authentication">
        <v-container fluid class="pa-3">
            <v-row class="h-100vh d-flex justify-center align-center">
                <v-col cols="12" lg="4" xl="3" class="d-flex align-center">
                    <v-card elevation="10" class="px-sm-1 px-0  mx-auto" max-width="500">
                        <v-card-item class="pa-sm-8">
                            <div class="d-flex justify-center py-4">
                                <Logo />
                            </div>
                            <div class="text-body-1 text-muted text-center mb-3">Your Social Campaigns</div>
                            <form @submit.prevent="handleLogin">
                                <v-text-field
                                    v-model="email"
                                    label="Email"
                                    required
                                ></v-text-field>
                                <v-text-field
                                    v-model="password"
                                    label="Password"
                                    type="password"
                                    required
                                ></v-text-field>
                                <v-btn type="submit" color="primary" class="mt-4">Login</v-btn>
                                <p v-if="error" class="text-red">{{ error }}</p>
                            </form>
                            <h6 class="text-h6 text-muted font-weight-medium d-flex justify-center align-center mt-3">
                                New to Matdash?
                                <RouterLink to="/auth/register"
                                    class="text-primary text-decoration-none text-body-1 opacity-1 font-weight-medium pl-2">
                                    Create an account</RouterLink>
                            </h6>
                        </v-card-item>
                    </v-card>
                </v-col>
            </v-row>
        </v-container>
    </div>
</template>

<style scoped>
.text-red {
    color: red;
}
</style>