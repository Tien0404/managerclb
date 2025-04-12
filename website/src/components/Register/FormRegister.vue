<template>
  <EmailVerification
    v-if="showVerification"
    :email="formData.email"
  />
  <div v-else class="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-blue-50 relative overflow-hidden">
    <!-- Animated Background Elements -->
    <div class="absolute inset-0">
      <div class="absolute top-0 left-0 w-72 h-72 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob"></div>
      <div class="absolute top-1/4 right-0 w-72 h-72 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob animation-delay-2000"></div>
      <div class="absolute -bottom-8 left-1/4 w-72 h-72 bg-pink-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob animation-delay-4000"></div>
    </div>

    <!-- Main Container with Split Design -->
    <div class="w-full max-w-6xl h-[36rem] p-0 bg-white rounded-2xl shadow-2xl flex overflow-hidden relative">
      <!-- Left Side - Illustration -->
      <div class="w-2/5 bg-gradient-to-br from-primary/5 to-accent/5 relative overflow-hidden">
        <!-- Background Animation -->
        <div class="absolute inset-0">
          <div class="absolute top-0 left-0 w-full h-full bg-gradient-to-br from-primary/10 to-accent/10 animate-gradient-slow"></div>
        </div>
        
        <!-- Content -->
        <div class="relative z-10 h-full flex flex-col">
          <!-- Image Container -->
          <div class="flex-1 flex items-center justify-center">
            <img src="../../assets/log-in.png" alt="Register" class="w-80 h-80 object-contain animate-float-slow" />
          </div>
          
          <!-- Text Container -->
          <div class="text-center pb-8">
            <h2 class="text-2xl font-bold text-gray-800 mb-3">Tham gia cùng chúng tôi!</h2>
            <p class="text-gray-600">Tạo tài khoản để bắt đầu</p>
          </div>
        </div>

        <!-- Decorative Elements -->
        <div class="absolute bottom-0 left-0 w-full">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320" class="opacity-20">
            <path fill="currentColor" fill-opacity="1" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,112C672,96,768,96,864,112C960,128,1056,160,1152,160C1248,160,1344,128,1392,112L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
          </svg>
        </div>
      </div>

      <!-- Right Side - Registration Form -->
      <div class="w-3/5 p-10">
        <div class="max-w-2xl mx-auto h-full flex flex-col justify-center">
          <!-- Header -->
          <div class="text-center mb-6">
            <h1 class="text-3xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
              Đăng Ký
            </h1>
            <div class="mt-2 w-16 h-1 bg-gradient-to-r from-primary to-accent rounded-full mx-auto"></div>
          </div>

          <!-- Success Message -->
          <div v-if="successMessage" class="mb-4 p-3 bg-green-50 border border-green-200 rounded-xl">
            <p class="text-green-600 text-center">{{ successMessage }}</p>
          </div>

          <!-- Registration Form -->
          <form @submit.prevent="handleSubmit" class="grid grid-cols-2 gap-5">
            <!-- Email Input -->
            <div class="space-y-2">
              <label class="text-sm font-medium text-gray-700 block">Email</label>
              <div class="relative">
                <input
                  type="email"
                  v-model="formData.email"
                  class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                  required
                />
                <MailIcon class="w-6 h-6 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
              </div>
            </div>

            <!-- Phone Input -->
            <div class="space-y-2">
              <label class="text-sm font-medium text-gray-700 block">Số điện thoại</label>
              <div class="relative">
                <input
                  type="tel"
                  v-model="formData.phone"
                  class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                  required
                />
                <PhoneIcon class="w-6 h-6 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
              </div>
            </div>

            <!-- Password Input -->
            <div class="space-y-2">
              <label class="text-sm font-medium text-gray-700 block">Mật khẩu</label>
              <div class="relative">
                <input
                  type="password"
                  v-model="formData.password"
                  class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                  required
                />
                <LockIcon class="w-6 h-6 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
              </div>
            </div>

            <!-- Repeat Password Input -->
            <div class="space-y-2">
              <label class="text-sm font-medium text-gray-700 block">Nhập lại mật khẩu</label>
              <div class="relative">
                <input
                  type="password"
                  v-model="formData.password_confirmation"
                  class="w-full px-12 py-4 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300 text-gray-700"
                  required
                />
                <KeyIcon class="w-6 h-6 text-gray-400 absolute left-4 top-1/2 transform -translate-y-1/2" />
              </div>
            </div>

            <!-- Error Message -->
            <div v-if="errorMessage" class="col-span-2 text-red-500 text-sm text-center animate-shake">
              {{ errorMessage }}
            </div>

            <!-- Register Button -->
            <button
              type="submit"
              :disabled="isLoading"
              class="col-span-2 py-4 text-lg font-medium text-white bg-gradient-to-r from-primary to-accent rounded-xl shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-300 relative overflow-hidden group disabled:opacity-70 disabled:cursor-not-allowed"
            >
              <span class="relative z-10 flex items-center justify-center gap-2">
                <span v-if="isLoading" class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                {{ isLoading ? 'Đang xử lý...' : 'Đăng Ký' }}
              </span>
              <div class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
            </button>

            <!-- Sign In Link -->
            <div class="col-span-2 text-center space-x-2 mt-4">
              <span class="text-gray-500">Đã có tài khoản?</span>
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

<script setup>
import { ref } from "vue"
import { UserIcon, LockIcon, MailIcon, PhoneIcon, KeyIcon } from "lucide-vue-next"
import { register } from "../../services/auth"
import { useRouter } from "vue-router"
import EmailVerification from './EmailVerification.vue'

const router = useRouter()

const formData = ref({
    email: "",
    password: "",
    password_confirmation: "",
    phone: ""
})

const errorMessage = ref("")
const successMessage = ref("")
const isLoading = ref(false)

const validateForm = () => {
    if (!formData.value.email || !formData.value.password || !formData.value.phone || !formData.value.password_confirmation) {
        errorMessage.value = "Vui lòng điền đầy đủ thông tin!"
        return false
    }

    if (formData.value.password !== formData.value.password_confirmation) {
        errorMessage.value = "Mật khẩu không khớp!"
        return false
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.value.email)) {
        errorMessage.value = "Email không hợp lệ!"
        return false
    }

    const phoneRegex = /(84|0[3|5|7|8|9])+([0-9]{8})\b/
    if (!phoneRegex.test(formData.value.phone)) {
        errorMessage.value = "Số điện thoại không hợp lệ!"
        return false
    }

    if (formData.value.password.length < 8) {
        errorMessage.value = "Mật khẩu phải có ít nhất 8 ký tự!"
        return false
    }

    return true
}

const showVerification = ref(false)

const handleSubmit = async () => {
    errorMessage.value = ""
    if (!validateForm()) return

    try {
        console.log('Form data being submitted:', formData.value)
        isLoading.value = true
        const response = await register({
            email: formData.value.email,
            password: formData.value.password,
            password_confirmation: formData.value.password_confirmation,
            phone: formData.value.phone
        })
        console.log('Registration successful. Server response:', response)
        successMessage.value = "Đăng ký thành công! Vui lòng nhập mã xác thực đã được gửi đến email của bạn."
        localStorage.setItem('verifyEmail', formData.value.email)
        setTimeout(() => {
            router.push('/email-verification')
        }, 1000)
    } catch (error) {
        console.error('Registration error:', error)
        if (error.response?.data?.errors) {
            const errors = error.response.data.errors
            console.log('Validation errors:', errors)
            errorMessage.value = Object.values(errors)[0][0]
        } else {
            errorMessage.value = error.response?.data?.message || "Có lỗi xảy ra khi đăng ký!"
        }
    } finally {
        isLoading.value = false
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

