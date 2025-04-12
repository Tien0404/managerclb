<template>
    <aside class="w-64 h-screen bg-white border-r border-gray-200 flex flex-col fixed">
        <router-link to="/">
        <div class="p-4 flex items-center gap-2">
            
            <div class=" h-8 rounded-full flex items-center justify-center">
                <img src="../assets/vaa.svg" alt="Logo" class="h-10 mr-3" />
            </div>
            <span class="font-semibold text-gray-800">VAA</span>
        </div>
    </router-link>
        <nav class="flex-1 px-2 py-4">
            <ul class="space-y-1">
                <!-- Dashboard -->
                <li>
                    <router-link :to="`/club/${currentClubId}/dashboard`" class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg"
                        :class="{ 'text-blue-600 bg-sky-500/5': currentRoute === 'dashboard', 'text-gray-700': currentRoute !== 'dashboard' }">
                        <HomeIcon class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'dashboard', 'text-gray-700': currentRoute !== 'dashboard' }" />
                        <span>Dashboard</span>
                    </router-link>
                </li>

                <!-- Club Info -->
                <li>
                    <router-link :to="`/club/${currentClubId}/update-info-club`" class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg"
                        :class="{ 'text-blue-600': currentRoute === 'update-info-club', 'text-gray-700': currentRoute !== 'update-info-club' }">
                        <InfoIcon class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'update-info-club', 'text-gray-700': currentRoute !== 'update-info-club' }" />
                        <span>Thông tin CLB</span>
                    </router-link>
                </li>

                <!-- Layout Grid -->
                <li>
                    <router-link :to="`/club/${currentClubId}/quan-ly-trang-dai-dien`"
                        class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg"
                        :class="{ 'text-blue-600 bg-sky-500/5': currentRoute === 'quan-ly-trang-dai-dien', 'text-gray-700': currentRoute !== 'quan-ly-trang-dai-dien' }">
                        <LayoutGridIcon class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'quan-ly-trang-dai-dien', 'text-gray-700': currentRoute !== 'quan-ly-trang-dai-dien' }" />
                        <span>Quản lý Trang đại diện</span>
                    </router-link>
                </li>

                <!-- Member Management -->
                <li>
                    <router-link :to="`/club/${currentClubId}/quan-ly-thanh-vien`"
                        class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg"
                        :class="{ 'text-blue-600 bg-sky-500/5': currentRoute === 'quan-ly-thanh-vien', 'text-gray-700': currentRoute !== 'quan-ly-thanh-vien' }">
                        <UsersIcon class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'quan-ly-thanh-vien', 'text-gray-700': currentRoute !== 'quan-ly-thanh-vien' }" />
                        <span>Quản lý Thành viên</span>
                    </router-link>
                </li>

                <!-- Event Management -->
                <li>
                    <router-link :to="`/club/${currentClubId}/quan-ly-su-kien`"
                        class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg" :class="{
                            'text-blue-600 bg-sky-500/5': currentRoute === 'quan-ly-su-kien', 'text-gray-700': currentRoute
                                !== 'quan-ly-su-kien'
                        }">
                        <CalendarIcon class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'quan-ly-su-kien', 'text-gray-700': currentRoute !== 'quan-ly-su-kien' }" />
                        <span>Quản lý Sự Kiện</span>
                        <ChevronDownIcon class="w-4 h-4 ml-auto transition-transform duration-200"
                            :class="{ 'rotate-180': isEventMenuOpen }" />
                    </router-link>
                </li>

                <!-- Blog Management -->
                <li>
                    <router-link :to="`/club/${currentClubId}/quan-ly-blog`"
                        class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg" :class="{
                            'text-blue-600 bg-sky-500/5': currentRoute === 'quan-ly-blog', 'text-gray-700': currentRoute
                                !== 'quan-ly-blog'
                        }">
                        <NotebookText class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'quan-ly-blog', 'text-gray-700': currentRoute !== 'quan-ly-blog' }" />
                        <span>Quản lý Blog</span>
                    </router-link>
                </li>

                <!-- Feedback Management -->
                <li>
                    <router-link :to="`/club/${currentClubId}/quan-ly-phan-hoi`"
                        class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg" :class="{
                            'text-blue-600 bg-sky-500/5': currentRoute === 'quan-ly-phan-hoi', 'text-gray-700': currentRoute
                                !== 'quan-ly-phan-hoi'
                        }">
                        <MessageSquare class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'quan-ly-phan-hoi', 'text-gray-700': currentRoute !== 'quan-ly-phan-hoi' }" />
                        <span>Quản lý Phản hồi</span>
                    </router-link>
                </li>
            </ul>
        </nav>
    </aside>
</template>

<script setup>
import { computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useDepartmentStore } from '../stores/departmentStore';
import {
    HomeIcon,
    InfoIcon,
    LayoutGridIcon,
    UsersIcon,
    CalendarIcon,
    ChevronDownIcon,
    ChevronUpIcon,
    UserIcon,
    NotebookText,
    MessageSquare
} from 'lucide-vue-next'

const route = useRoute();
const currentRoute = computed(() => route.name);
const currentClubId = computed(() => route.params.id || null);

// Initialize department store
const departmentStore = useDepartmentStore();

// Check user permissions when component is mounted
onMounted(async () => {
    if (currentClubId.value) {
        await departmentStore.checkUserDepartment(currentClubId.value);
        console.log('User Permissions:', {
            canManageClubs: departmentStore.canManageClubs,
            canManageMembers: departmentStore.canManageMembers,
            canManageEvents: departmentStore.canManageEvents,
            canManageBlogs: departmentStore.canManageBlogs,
            canManageFeedback: departmentStore.canManageFeedback
        });
    }
});

// Computed properties for permissions
const canManageMembers = computed(() => departmentStore.canManageMembers);
const canManageEvents = computed(() => departmentStore.canManageEvents);
const canManageBlogs = computed(() => departmentStore.canManageBlogs);
const canManageFeedback = computed(() => departmentStore.canManageFeedback);
const canManageClubs = computed(() => departmentStore.canManageClubs);
</script>
