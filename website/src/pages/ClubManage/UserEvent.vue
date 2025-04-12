<template>
    <div class="p-6 bg-gray-50 min-h-screen">
        <!-- Header -->
        <div class="flex justify-between items-center mb-8">
            <div>
                <h1 class="text-xl font-semibold">Quản lý nguời tham gia sự kiện</h1>
                <p class="text-gray-500 mt-1">{{ eventName }}</p>
            </div>
            <div class="flex gap-2">
                <button @click="toggleEditing" class="flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-all">
                    <PencilIcon class="w-5 h-5" />
                    <span>{{ isEditing ? 'Khóa chỉnh sửa' : 'Chỉnh sửa' }}</span>
                </button>
                <button @click="goBack" class="flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-all">
                    <ArrowLeftIcon class="w-5 h-5" />
                    <span>Quay lại</span>
                </button>
            </div>
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
                Chưa có thành viên nào tham gia sự kiện này
            </div>

            <!-- Table -->
            <table v-else class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="text-left py-3 px-4">Thành viên</th>
                        <th class="text-left py-3 px-4">Thông tin Liên hệ</th>
                        <th class="text-left py-3 px-4">Thời gian đăng ký</th>
                        <th class="text-left py-3 px-4">Trạng thái</th>
                        <th class="text-center py-3 px-4">Phê duyệt tham gia</th>
                        <th class="text-left py-3 px-4"></th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="member in members" :key="member.id" class="border-b">
                        <td class="py-4 px-4">
                            <div class="flex items-center gap-3">
                                <img :src="member.avatar" alt="" class="w-10 h-10 rounded-full">
                                <div>
                                    <span class="font-medium">{{ member.user?.username || 'Không có tên' }}</span>
                                    <p class="text-sm text-gray-500">{{ member.user?.role || 'Chưa có vai trò' }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="py-4 px-4">
                            <div>
                                <p class="text-gray-500">{{ member.user?.phone || 'Chưa có SĐT' }}</p>
                                <p class="text-gray-500">{{ member.user?.email || 'Chưa có email' }}</p>
                            </div>
                        </td>
                        <td class="py-4 px-4">
                            <p class="text-gray-500">{{ new Date(member.created_at).toLocaleString('vi-VN') }}</p>
                        </td>
                        <td class="py-4 px-4">
                            <span :class="getStatusClass(member.status)" class="px-2 py-1 rounded-full text-sm">
                                {{ getStatusDisplay(member.status) }}
                            </span>
                        </td>
                        <td class="py-4 px-4 text-center">
                            <input type="checkbox" 
                                   :checked="member.status === 'approved'"
                                   @change="handleApprovalChange(member)"
                                   :disabled="!isEditing"
                                   class="w-4 h-4 text-green-600 bg-gray-100 border-gray-300 rounded focus:ring-green-500 focus:ring-2">
                        </td>
                    
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>

<script>
import {
    PlusIcon,
    SearchIcon,
    FilterIcon,
    MessageSquareIcon,
    Trash2Icon,
    ArrowLeftIcon,
    PencilIcon
} from 'lucide-vue-next';
import { useJoinRequestStore } from '../../stores/joinRequestStore';
import { storeToRefs } from 'pinia';

export default {
    components: {
        PlusIcon,
        SearchIcon,
        FilterIcon,
        MessageSquareIcon,
        Trash2Icon,
        ArrowLeftIcon,
        PencilIcon
    },
    setup() {
        const store = useJoinRequestStore();
        const { joinRequests: members, isLoading: loading, error } = storeToRefs(store);
        return {
            members,
            loading,
            error,
            store
        }
    },
    data() {
        return {
            eventName: '',
            eventId: null,
            clubId: null,
            isEditing: false
        }
    },
    methods: {
        toggleEditing() {
            this.isEditing = !this.isEditing;
        },
        getStatusDisplay(status) {
            switch (status) {
                case 'approved': return 'Đã tham gia';
                case 'rejected': return 'Không tham gia';
                default: return status;
            }
        },
        getStatusClass(status) {
            switch (status) {
                case 'approved': return 'bg-green-100 text-green-800';
                case 'rejected': return 'bg-red-100 text-red-800';
                default: return 'bg-gray-100 text-gray-800';
            }
        },
        async handleApprovalChange(member) {
            try {
                const newStatus = member.status === 'approved' ? 'rejected' : 'approved';
                await this.store.updateJoinRequest(member.id, { status: newStatus, type: 'event' });
                await this.fetchUserEvents(); // Tải lại dữ liệu sau khi cập nhật
            } catch (error) {
                console.error('Lỗi khi cập nhật trạng thái:', error);
            }
        },
        async fetchUserEvents() {
            await this.store.fetchEventRequests(this.eventId);
            console.log('Dữ liệu từ store - joinRequests:', this.members);
            this.eventName = `Danh sách người tham gia - Event #${this.eventId}`;
        },
        goBack() {
            this.$router.push(`/club/${this.clubId}/quan-ly-su-kien`);
        }
    },
    async created() {
        this.eventId = this.$route.params.id;
        this.clubId = localStorage.getItem('currentClubId');
        await this.fetchUserEvents();
    }
}
</script>