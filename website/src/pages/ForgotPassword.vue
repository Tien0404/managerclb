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
          <img src="../assets/family.png" alt="Forgot Password" class="w-64 h-64 object-contain mb-8 animate-float-slow" />
          <h2 class="text-2xl font-bold text-gray-800 mb-4">Quên mật khẩu?</h2>
          <p class="text-gray-600">Đừng lo lắng! Chúng tôi sẽ giúp bạn khôi phục tài khoản</p>
        </div>

        <!-- Decorative Elements -->
        <div class="absolute bottom-0 left-0 w-full">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320" class="opacity-20">
            <path fill="currentColor" fill-opacity="1" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,112C672,96,768,96,864,112C960,128,1056,160,1152,160C1248,160,1344,128,1392,112L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
          </svg>
        </div>
      </div>

      <!-- Right Side - Form -->
      <div class="w-1/2 p-12">
        <div class="max-w-md mx-auto">
          <!-- Header -->
          <div class="text-center mb-8">
            <h1 class="text-3xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
              Quên Mật Khẩu
            </h1>
            <div class="mt-2 w-16 h-1 bg-gradient-to-r from-primary to-accent rounded-full mx-auto"></div>
          </div>

          <!-- Form -->
          <form @submit.prevent="handleSubmit" class="space-y-6">
            <!-- Email Input -->
            <div class="space-y-2">
              <label class="text-sm font-medium text-gray-700 block">Email</label>
              <div class="relative">
                <input
                  type="email"
                  v-model="email"
                  class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                  required
                />
                <UserIcon class="w-5 h-5 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
              </div>
            </div>

            <!-- Error Message -->
            <div v-if="error" class="text-red-500 text-sm text-center animate-shake">
              {{ error }}
            </div>

            <!-- Success Message -->
            <div v-if="message" class="text-green-500 text-sm text-center">
              {{ message }}
            </div>

            <!-- Submit Button -->
            <button
              type="submit"
              :disabled="loading"
              class="w-full py-4 text-lg font-medium text-white bg-gradient-to-r from-primary to-accent rounded-xl shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-300 relative overflow-hidden group disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span class="relative z-10">
                <span v-if="loading">Đang xử lý...</span>
                <span v-else>Gửi liên kết đặt lại mật khẩu</span>
              </span>
              <div class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
            </button>

            <!-- Back to Login Link -->
            <div class="text-center space-y-2">
              <p class="text-gray-500">Đã nhớ mật khẩu?</p>
              <router-link 
                to="/login" 
                class="inline-block font-semibold text-primary hover:text-accent transition-colors duration-300"
              >
                Đăng Nhập Ngay
              </router-link>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { forgotPassword } from '../services/auth'

export default {
  name: 'ForgotPassword',
  data() {
    return {
      email: '',
      loading: false,
      message: '',
      error: ''
    }
  },
  methods: {
    async handleSubmit() {
      this.loading = true
      this.message = ''
      this.error = ''
      try {
        await forgotPassword(this.email)
        this.message = 'Liên kết đặt lại mật khẩu đã được gửi đến email của bạn'
        localStorage.setItem('resetPasswordEmail', this.email)
        setTimeout(() => {
          this.$router.push('/reset-password')
        }, 0)
        this.email = ''
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    }
  }
}
</script>