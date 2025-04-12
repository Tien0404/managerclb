<template>
    <aside class="w-64 bg-white border-r border-gray-200 flex flex-col fixed mt-20">
        <nav class="flex-1 px-2 py-4">
            <ul class="space-y-1">
                <!-- Profile -->
                <li>
                    <router-link to="/profile" class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg"
                        :class="{ 'text-blue-600 bg-sky-500/5': currentRoute === 'profile', 'text-gray-700': currentRoute !== 'profile' }">
                        <HomeIcon class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'profile', 'text-gray-700': currentRoute !== 'profile' }" />
                        <span>Thông Tin Cá Nhân</span>
                    </router-link>
                </li>

                <!-- History Event -->
                <li>
                    <router-link to="/profile/historyEvent" class="flex items-center px-4 py-2 hover:bg-gray-100 rounded-lg"
                        :class="{ 'text-blue-600': currentRoute === 'historyEvent', 'text-gray-700': currentRoute !== 'historyEvent' }">
                        <History class="w-5 h-5 mr-3"
                            :class="{ 'text-blue-600': currentRoute === 'historyEvent', 'text-gray-700': currentRoute !== 'historyEvent' }" />
                        <span>Lịch Sử Tham Gia Sự Kiện</span>
                    </router-link>
                </li>
            </ul>
        </nav>
    </aside>
</template>

<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import {
    HomeIcon,
    History,
} from 'lucide-vue-next'

const route = useRoute();

const currentRoute = computed(() => route.name);

</script>
