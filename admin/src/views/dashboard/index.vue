<script setup lang="ts">
/*Call Components*/
import RevenueCard from '@/components/dashboard/RevenueCard.vue';
import NewCustomer from '@/components/dashboard/NewCustomer.vue';
import Totalincome from '@/components/dashboard/TotalIncome.vue';
import RevenueProduct from '@/components/dashboard/RevenueProducts.vue';
import DailyActivities from '@/components/dashboard/DailyActivities.vue';
import BlogCards from '@/components/dashboard/BlogCards.vue';

/* Import Stores */
import { useUserStore, useClubStore, useCategoryStore, useEventStore, useFeedbackStore, useBlogStore } from '@/stores';
import { onMounted } from 'vue';

/* Initialize Stores */
const userStore = useUserStore();
const clubStore = useClubStore();
const categoryStore = useCategoryStore();
const eventStore = useEventStore();
const feedbackStore = useFeedbackStore();
const blogStore = useBlogStore();

/* Fetch Data on Component Mount */
onMounted(async () => {
    try {
        const [users, clubs, categories, events, feedbacks, blogs] = await Promise.all([
            userStore.fetchUsers(),
            clubStore.fetchClubs(),
            categoryStore.fetchCategories(),
            eventStore.fetchEvents(),
            feedbackStore.fetchFeedbacks(),
            blogStore.fetchBlogs()
        ]);
        console.log('Dữ liệu người dùng:', users);
        console.log('Dữ liệu câu lạc bộ:', clubs);
        console.log('Dữ liệu danh mục:', categories);
        console.log('Dữ liệu sự kiện:', events);
        console.log('Dữ liệu phản hồi:', feedbacks);
        console.log('Dữ liệu bài viết:', blogs);
    } catch (error) {
        console.error('Error fetching dashboard data:', error);
    }
});
</script>

<template>
    <v-row>
        <v-col cols="12" lg="8"><RevenueCard /></v-col>
        <v-col cols="12" lg="4"
            ><NewCustomer class="mb-6" />
            <Totalincome />
        </v-col>
        <v-col cols="12" lg="8"><RevenueProduct/></v-col>
        <v-col cols="12" lg="4"><DailyActivities/> </v-col>
        <v-col cols="12"><BlogCards/></v-col>
    </v-row>
</template>
