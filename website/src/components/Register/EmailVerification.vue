<template>
    <div
        class="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-blue-50 relative overflow-hidden">
        <!-- Animated Background Elements -->
        <div class="absolute inset-0">
            <div
                class="absolute top-0 left-0 w-72 h-72 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob">
            </div>
            <div
                class="absolute top-1/4 right-0 w-72 h-72 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob animation-delay-2000">
            </div>
            <div
                class="absolute -bottom-8 left-1/4 w-72 h-72 bg-pink-200 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-blob animation-delay-4000">
            </div>
        </div>

        <!-- Main Container -->
        <div class="w-full max-w-lg p-8 bg-white rounded-2xl shadow-2xl relative z-10">
            <div class="text-center mb-8">
                <h1
                    class="text-3xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent mb-2">
                    Xác Thực Email
                </h1>
                <div class="mt-2 w-16 h-1 bg-gradient-to-r from-primary to-accent rounded-full mx-auto"></div>
                <p class="mt-4 text-gray-600">Vui lòng nhập mã xác thực đã được gửi đến email của bạn</p>
                <p class="font-medium text-gray-800">{{ email }}</p>
            </div>

            <!-- OTP Input Form -->
            <form @submit.prevent="handleSubmit" class="space-y-6">
                <div class="flex justify-center gap-2">
                    <template v-for="(digit, index) in 6" :key="index">
                        <input type="text" :ref="el => otpInputs[index] = el" v-model="otpDigits[index]" maxlength="1"
                            class="w-12 h-12 text-center text-xl font-bold bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-300"
                            @input="handleInput(index)" @keydown="handleKeydown($event, index)" @paste="handlePaste" />
                    </template>
                </div>

                <!-- Error Message -->
                <div v-if="errorMessage" class="text-red-500 text-sm text-center animate-shake">
                    {{ errorMessage }}
                </div>

                <!-- Success Message -->
                <div v-if="successMessage" class="text-green-500 text-sm text-center">
                    {{ successMessage }}
                </div>

                <!-- Submit Button -->
                <button type="submit" :disabled="isLoading || !isOtpComplete || isResending"
                    class="w-full py-4 text-lg font-medium text-white bg-gradient-to-r from-primary to-accent rounded-xl shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-300 relative overflow-hidden group disabled:opacity-70 disabled:cursor-not-allowed">
                    <span class="relative z-10 flex items-center justify-center gap-2">
                        <span v-if="isLoading"
                            class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                        {{ isLoading ? 'Đang xử lý...' : 'Xác Thực' }}
                    </span>
                    <div
                        class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700">
                    </div>
                </button>

                <!-- Resend Button -->
                <div class="text-center">
                    <button type="button" @click="resendOtp" :disabled="resendCountdown > 0 || isLoading || isResending"
                        class="text-primary hover:text-accent transition-colors duration-300 disabled:opacity-50 disabled:cursor-not-allowed">
                        {{ resendCountdown > 0 ? `Gửi lại mã sau ${resendCountdown}s` : 'Gửi lại mã' }}
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { verifyEmail, resendVerificationCode } from '../../services/auth'
const email = ref(localStorage.getItem('verifyEmail') || '')

const router = useRouter()
const otpDigits = ref(Array(6).fill(''))
const otpInputs = ref([])
const errorMessage = ref('')
const successMessage = ref('')
const isLoading = ref(false)
const isResending = ref(false)
const resendCountdown = ref(0)

const isOtpComplete = computed(() => {
    return otpDigits.value.every(digit => digit !== '')
})

const handleInput = (index) => {
    let value = otpDigits.value[index]
    // Only allow numbers
    if (!/^\d*$/.test(value)) {
        otpDigits.value[index] = value.replace(/\D/g, '')
        return
    }
    if (value) {
        // Move to next input
        if (index < 5) {
            otpInputs.value[index + 1].focus()
        }
    }
}

const handleKeydown = (event, index) => {
    if (event.key === 'Backspace' && !otpDigits.value[index] && index > 0) {
        // Move to previous input on backspace
        otpInputs.value[index - 1].focus()
    }
}

const handlePaste = (event) => {
    event.preventDefault()
    const pastedData = event.clipboardData.getData('text')
    const digits = pastedData.slice(0, 6).split('')
    digits.forEach((digit, index) => {
        if (/^\d$/.test(digit) && index < 6) {
            otpDigits.value[index] = digit
        }
    })
}

const startResendCountdown = () => {
    resendCountdown.value = 60
    const timer = setInterval(() => {
        if (resendCountdown.value > 0) {
            resendCountdown.value--
        } else {
            clearInterval(timer)
        }
    }, 1000)
}

const resendOtp = async () => {
    try {
        isResending.value = true
        errorMessage.value = ''
        successMessage.value = ''
        console.log('Resending OTP for email:', email.value)
        await resendVerificationCode(email.value)
        console.log('OTP resent successfully')
        successMessage.value = 'Mã xác thực mới đã được gửi đến email của bạn'
        startResendCountdown()
    } catch (error) {
        console.error('Error resending OTP:', error)
        errorMessage.value = error.message
    } finally {
        isResending.value = false
    }
}

const handleSubmit = async () => {
    if (!isOtpComplete.value) return

    try {
        isLoading.value = true
        errorMessage.value = ''
        successMessage.value = ''
        const otp = otpDigits.value.join('')
        console.log('Submitting verification with:', { email: email.value, otp })

        const response = await verifyEmail({
            email: email.value,
            otp: otp
        })

        console.log('Server response:', response)
        if (response) {
            successMessage.value = 'Xác thực email thành công!'
            localStorage.removeItem('verifyEmail') // Xóa email đã lưu sau khi xác thực thành công
            // Đợi một chút để người dùng thấy thông báo thành công
            await new Promise(resolve => setTimeout(resolve, 1500))
            router.push('/login')
        } else {
            const errorMsg = response.data?.message || response.message || 'Xác thực email không thành công'
            throw new Error(errorMsg)
        }
    } catch (error) {
        console.error('Verification error:', error)
        errorMessage.value = error.message
        otpDigits.value = Array(6).fill('')
        otpInputs.value[0]?.focus()
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    otpInputs.value[0]?.focus()
    startResendCountdown()
})
</script>

<style scoped>
@keyframes blob {

    0%,
    100% {
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

@keyframes shake {

    0%,
    100% {
        transform: translateX(0);
    }

    25% {
        transform: translateX(-5px);
    }

    75% {
        transform: translateX(5px);
    }
}

.animate-shake {
    animation: shake 0.5s ease-in-out;
}
</style>