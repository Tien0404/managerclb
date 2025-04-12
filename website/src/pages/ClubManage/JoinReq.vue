<template>
    <div class="p-6 bg-gray-50 min-h-screen">
        <!-- Header -->
        <div class="flex justify-between items-center mb-8">
            <div>
                <h1 class="text-xl font-semibold">Danh sách yêu cầu tham gia câu lạc bộ</h1>
                <p class="text-gray-500 mt-1">{{ clubName }}</p>
            </div>
            <button @click="goBack" class="flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-all">
                <ArrowLeftIcon class="w-5 h-5" />
                <span>Quay lại</span>
            </button>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="flex justify-center items-center py-8">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4">
            {{ error }}
        </div>

        <!-- Member List -->
        <div v-else class="bg-white rounded-lg p-6">
            <!-- Search and Filter -->
            <div class="flex gap-4 mb-4">
                <div class="flex-1 relative">
                    <SearchIcon class="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                    <input type="text" placeholder="Tìm kiếm thành viên" 
                           class="w-full pl-10 pr-4 py-2 border rounded-lg">
                </div>
                <button class="px-4 py-2 border rounded-lg flex items-center gap-2">
                    <FilterIcon class="w-4 h-4" />
                    Lọc theo
                </button>
            </div>

            <!-- Empty State -->
            <div v-if="members.length === 0" class="text-center py-8 text-gray-500">
                Chưa có yêu cầu tham gia nào
            </div>

            <!-- Table -->
            <table v-else class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="text-left py-3 px-4">Thành viên</th>
                        <th class="text-left py-3 px-4">Thông tin Liên hệ</th>
                        <th class="text-left py-3 px-4">Trạng thái</th>
                        <th class="text-left py-3 px-4">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="member in members" :key="member.id" class="border-b">
                        <td class="py-4 px-4">
                            <div class="flex items-center gap-3">
                                <img :src="member.avatar" alt="" class="w-10 h-10 rounded-full">
                                <div>
                                    <span class="font-medium">{{ member.name }}</span>
                                    <p class="text-sm text-gray-500">{{ member.role }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="py-4 px-4">
                            <div>
                                <p class="text-gray-500">{{ member.phone }}</p>
                                <p class="text-gray-500">{{ member.email }}</p>
                            </div>
                        </td>
                        <td class="py-4 px-4">
                            <span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm">
                                Đang chờ duyệt
                            </span>
                        </td>
                        <td class="py-4 px-4">
                            <div class="flex gap-2">
                                <button @click="acceptRequest(member.id)" class="px-3 py-1 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
                                    Duyệt
                                </button>
                                <button @click="rejectRequest(member.id)" class="px-3 py-1 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors">
                                    Từ chối
                                </button>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <!-- Notification Component -->
        <Notification 
            :type="notificationType" 
            :message="notificationMessage" 
            :duration="notificationDuration" 
            v-model:show="showNotification" 
        />
    </div>
</template>

<script>
import {
    PlusIcon,
    SearchIcon,
    FilterIcon,
    MessageSquareIcon,
    Trash2Icon,
    ArrowLeftIcon
} from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useJoinRequestStore } from '../../stores/joinRequestStore'
import { useClubStore } from '../../stores/clubStore'
import Notification from '../../components/Notification.vue'
import { useNotification } from '../../composables/useNotification'

export default {
    components: {
        PlusIcon,
        SearchIcon,
        FilterIcon,
        MessageSquareIcon,
        Trash2Icon,
        ArrowLeftIcon,
        Notification
    },
    setup() {
        const route = useRoute()
        const router = useRouter()
        const clubId = ref(route.params.id)
        const clubName = ref('')
        const members = ref([])
        const loading = ref(false)
        const error = ref(null)
        const joinRequestStore = useJoinRequestStore()
        const clubStore = useClubStore()
        
        // Initialize notification
        const { 
            showNotification, 
            notificationType, 
            notificationMessage, 
            notificationDuration,
            showSuccess,
            showError
        } = useNotification()

        const fetchJoinRequests = async () => {
            try {
                loading.value = true
                await joinRequestStore.fetchClubRequests(clubId.value)
                await clubStore.fetchClubById(clubId.value)
                
                const pendingRequests = joinRequestStore.joinRequests.filter(request => request.status === 'request')
                members.value = pendingRequests.map(request => ({
                    id: request.id, // Thay đổi từ request.user.id thành request.id
                    name: request.user.username,
                    email: request.user.email,
                    phone: request.user.phone,
                    role: request.user.departments.name || 'Thành viên',
                    avatar: request.user.avatar || 'https://via.placeholder.com/40'
                }))
                
                clubName.value = clubStore.selectedClub?.name || `Câu lạc bộ #${clubId.value}`
            } catch (err) {
                error.value = 'Không thể tải danh sách yêu cầu tham gia'
                console.error('Error fetching join requests:', err)
            } finally {
                loading.value = false
            }
        }

        const acceptRequest = async (memberId) => {
            try {
                await joinRequestStore.updateJoinRequest(memberId, { status: 'approved' })
                showSuccess('Đã chấp nhận yêu cầu tham gia')
                await fetchJoinRequests()
            } catch (err) {
                showError('Không thể chấp nhận yêu cầu tham gia')
                console.error('Error accepting request:', err)
            }
        }

        const rejectRequest = async (memberId) => {
            try {
                await joinRequestStore.updateJoinRequest(memberId, { status: 'rejected' })
                showSuccess('Đã từ chối yêu cầu tham gia')
                await fetchJoinRequests()
            } catch (err) {
                showError('Không thể từ chối yêu cầu tham gia')
                console.error('Error rejecting request:', err)
            }
        }

        const goBack = () => {
            router.push(`/club/${clubId.value}/quan-ly-thanh-vien`)
        }

        onMounted(() => {
            fetchJoinRequests()
        })

        return {
            clubName,
            members,
            loading,
            error,
            acceptRequest,
            rejectRequest,
            goBack,
            // Return notification properties
            showNotification,
            notificationType,
            notificationMessage,
            notificationDuration
        }
    }
}
</script>