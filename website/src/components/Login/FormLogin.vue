<template>
    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-blue-50 relative overflow-hidden">
        <!-- Animated Background Elements -->
        <div class="absolute inset-0">
            <div class="absolute top-0 left-0 w-72 h-72 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob"></div>
            <div class="absolute top-1/4 right-0 w-72 h-72 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob animation-delay-2000"></div>
            <div class="absolute -bottom-8 left-1/4 w-72 h-72 bg-pink-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob animation-delay-4000"></div>
        </div>

        <!-- Main Container with Split Design -->
        <div class="w-full max-w-5xl p-0 bg-white rounded-2xl shadow-2xl flex overflow-hidden relative">
            <!-- Left Side - Illustration -->
            <div class="w-1/2 bg-gradient-to-br from-primary/5 to-accent/5 p-12 flex flex-col items-center justify-center relative overflow-hidden">
                <!-- Background Animation -->
                <div class="absolute inset-0">
                    <div class="absolute top-0 left-0 w-full h-full bg-gradient-to-br from-primary/10 to-accent/10 animate-gradient-slow"></div>
                </div>
                
                <!-- Content -->
                <div class="relative z-10 text-center">
                    <img src="../../assets/family.png" alt="Login" class="w-64 h-64 object-contain mb-8 animate-float-slow" />
                    <h2 class="text-2xl font-bold text-gray-800 mb-4">Chào mừng trở lại!</h2>
                    <p class="text-gray-600">Đăng nhập để quản lý câu lạc bộ của bạn</p>
                </div>

                <!-- Decorative Elements -->
                <div class="absolute bottom-0 left-0 w-full">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320" class="opacity-20">
                        <path fill="currentColor" fill-opacity="1" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,112C672,96,768,96,864,112C960,128,1056,160,1152,160C1248,160,1344,128,1392,112L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
                    </svg>
                </div>
            </div>

            <!-- Right Side - Login Form -->
            <div class="w-1/2 p-12">
                <div class="max-w-md mx-auto">
                    <!-- Header -->
                    <div class="text-center mb-8">
                        <h1 class="text-3xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                            Đăng Nhập
                        </h1>
                        <div class="mt-2 w-16 h-1 bg-gradient-to-r from-primary to-accent rounded-full mx-auto"></div>
                    </div>

                    <!-- Login Form -->
                    <form @submit.prevent="handleSubmit" class="space-y-6">
                        <!-- Email Input -->
                        <div class="space-y-2">
                            <label class="text-sm font-medium text-gray-700 block">Email</label>
                            <div class="relative">
                                <input
                                    type="text"
                                    v-model="email"
                                    class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                                    required
                                />
                                <UserIcon class="w-5 h-5 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
                            </div>
                        </div>

                        <!-- Password Input -->
                        <div class="space-y-2">
                            <label class="text-sm font-medium text-gray-700 block">Mật khẩu</label>
                            <div class="relative">
                                <input
                                    type="password"
                                    v-model="password"
                                    class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                                    required
                                />
                                <LockIcon class="w-5 h-5 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
                            </div>
                        </div>

                        <!-- Forgot Password Link -->
                        <div class="text-right">
                            <router-link 
                                to="/forgot-password" 
                                class="text-sm text-primary hover:text-accent transition-colors duration-300"
                            >
                                Quên mật khẩu?
                            </router-link>
                        </div>

                        <!-- Error Message -->
                        <div v-if="errorMessage" class="text-red-500 text-sm text-center animate-shake">
                            {{ errorMessage }}
                        </div>

                        <!-- Login Button -->
                        <button
                            type="submit"
                            class="w-full py-4 text-lg font-medium text-white bg-gradient-to-r from-primary to-accent rounded-xl shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-300 relative overflow-hidden group"
                        >
                            <span class="relative z-10">Đăng Nhập</span>
                            <div class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
                        </button>

                        <!-- Sign Up Link -->
                        <div class="text-center space-y-2">
                            <p class="text-gray-500">Chưa có tài khoản?</p>
                            <router-link 
                                to="/register" 
                                class="inline-block font-semibold text-primary hover:text-accent transition-colors duration-300"
                            >
                                Đăng Ký Ngay
                            </router-link>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import { UserIcon, LockIcon } from 'lucide-vue-next'
import { useRouter } from "vue-router"
import { useAuthStore } from '../../stores/authStore'

const authStore = useAuthStore()
const router = useRouter()
const email = ref('')
const password = ref('')
const errorMessage = ref("")

const handleSubmit = async () => {
    try {
        await authStore.loginUser({ email: email.value, password: password.value })
        router.push("/").then(() => {
            window.location.reload()
        })
    } catch (error) {
        errorMessage.value = error.response?.data?.message || error.message
    }
}
</script>

<style scoped>
@keyframes blob {
    0%, 100% {
        transform: translate(0, 0) scale(1);
    }
    25% {
        transform: translate(20px, -20px) scale(1.1);
    }
    50% {
        transform: translate(0, 20px) scale(1);
    }
    75% {
        transform: translate(-20px, -20px) scale(0.9);
    }
}

.animate-blob {
    animation: blob 15s infinite;
}

.animation-delay-2000 {
    animation-delay: 2s;
}

.animation-delay-4000 {
    animation-delay: 4s;
}

@keyframes gradient-slow {
    0% {
        background-position: 0% 50%;
    }
    50% {
        background-position: 100% 50%;
    }
    100% {
        background-position: 0% 50%;
    }
}

.animate-gradient-slow {
    background-size: 200% 200%;
    animation: gradient-slow 8s ease infinite;
}

@keyframes float {
    0%, 100% {
        transform: translateY(0);
    }
    50% {
        transform: translateY(-10px);
    }
}

.animate-float-slow {
    animation: float 4s ease-in-out infinite;
}

@keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-5px); }
    75% { transform: translateX(5px); }
}

.animate-shake {
    animation: shake 0.5s ease-in-out;
}

/* Custom scrollbar */
::-webkit-scrollbar {
    width: 8px;
}

::-webkit-scrollbar-track {
    background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
    background: linear-gradient(to bottom, var(--primary), var(--accent));
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(to bottom, var(--accent), var(--primary));
}
</style>
  