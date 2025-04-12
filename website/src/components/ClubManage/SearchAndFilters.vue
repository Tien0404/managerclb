<template>
    <div class="pt-4 pb-4 space-y-4">
        <div class="flex items-center space-x-4">
            <div class="flex-1 relative">
                <SearchIcon class="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input 
                    type="text" 
                    v-model="searchQuery" 
                    :placeholder="`Tìm kiếm ${type === 'blog' ? 'Blog' : 'Sự kiện'}`"
                    class="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div class="relative">
                <select
                    v-model="selectedCategory"
                    @change="handleCategoryChange"
                    class="appearance-none px-4 py-2 pr-8 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">Tất cả</option>
                    <option v-for="category in categories" :key="category.id" :value="category.id">
                        {{ category.name }}
                    </option>
                </select>
                <ChevronDownIcon
                    class="w-5 h-5 absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 pointer-events-none" />
            </div>
            <button class="p-2 border rounded-lg">
                <ArrowUpDownIcon class="w-5 h-5" />
            </button>
            <button @click="$emit('openModal')" class="flex items-center space-x-2 px-4 py-2 bg-black text-white rounded-lg">
                <PlusIcon class="w-5 h-5" />
                <span>Tạo {{ type === 'blog' ? 'Blog' : 'Sự kiện' }}</span>
            </button>
        </div>
    </div>
</template>

<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { SearchIcon, ChevronDownIcon, ArrowUpDownIcon, PlusIcon } from 'lucide-vue-next';
import { useBlogStore } from '../../stores/blogStore';
import { useEventStore } from '../../stores/eventStore';
import { useCategoryStore } from '../../stores/categoryStore';

const props = defineProps({
    type: {
        type: String,
        default: 'blog',
        validator: (value) => ['blog', 'event'].includes(value)
    }
});

const emit = defineEmits(['openModal']);

const blogStore = useBlogStore();
const eventStore = useEventStore();
const categoryStore = useCategoryStore();

const searchQuery = ref('');
const selectedCategory = ref('');

// Get categories based on type
const categories = computed(() => {
    return props.type === 'blog' ? categoryStore.blogCategories : categoryStore.eventCategories;
});

// Fetch categories on mount
onMounted(async () => {
    await categoryStore.fetchCategories();
});

// Debounce function
function debounce(fn, delay) {
    let timeoutId;
    return function (...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn.apply(this, args), delay);
    };
}

// Debounced search handler
const debouncedSearch = debounce((value) => {
    if (props.type === 'blog') {
        blogStore.setFilter('searchQuery', value);
        blogStore.fetchBlogs(true);
    } else {
        // For events
        eventStore.setFilter('searchQuery', value);
        // We don't need to fetch events again as the filteredEvents getter will handle filtering
    }
}, 300);

// Watch for changes in searchQuery
watch(searchQuery, (newValue) => {
    debouncedSearch(newValue);
});

// Handle category change
const handleCategoryChange = () => {
    if (props.type === 'blog') {
        blogStore.setFilter('category_id', selectedCategory.value);
        blogStore.fetchBlogs(true);
    } else {
        // For events
        eventStore.setFilter('category', selectedCategory.value);
        // We don't need to fetch events again as the filteredEvents getter will handle filtering
    }
};
</script>

<style scoped>
/* Add scoped styles here if needed */
</style> 