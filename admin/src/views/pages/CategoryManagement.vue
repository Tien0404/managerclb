<template>
    <v-container fluid class="pa-0">
        <v-card class="elevation-2">
            <v-toolbar color="primary" dark>
                <v-toolbar-title>Quản Lý Danh Mục</v-toolbar-title>
                <v-spacer></v-spacer>
            </v-toolbar>

            <v-card-text>
                <v-alert v-if="notification.message" :type="notification.type" :text="notification.message" class="mb-4" closable></v-alert>
                
                <v-row class="mb-4">
                    <v-col cols="12" sm="4">
                        <v-btn color="primary" @click="openAddDialog">Thêm Danh Mục</v-btn>
                    </v-col>
                    <v-col cols="12" sm="8">
                        <v-text-field
                            v-model="search"
                            label="Tìm kiếm"
                            prepend-icon="mdi-magnify"
                            single-line
                            hide-details
                            @input="() => {}"
                        ></v-text-field>
                    </v-col>
                </v-row>

                <v-data-table
                    :headers="headers"
                    :items="filteredCategories"
                    :items-per-page="itemsPerPage"
                    :page.sync="page"
                    class="elevation-1"
                >
                    <template v-slot:item.index="{ item }">
                        {{ filteredCategories.indexOf(item) + 1 + (page.value - 1) * itemsPerPage }}
                    </template>

                    <template v-slot:item.status="{ item }">
                        <v-chip
                            :color="item.status === 'active' ? 'success' : 'error'"
                            small
                        >
                            {{ item.status === 'active' ? 'Hoạt động' : 'Không hoạt động' }}
                        </v-chip>
                    </template>

                    <template v-slot:item.type="{ item }">
                        <v-chip small>
                            {{ item.type }}
                        </v-chip>
                    </template>

                    <template v-slot:item.actions="{ item }">
                        <v-btn small color="primary" @click="editCategory(item)">
                            <v-icon color="white">mdi-pencil</v-icon>
                        </v-btn>
                        <v-btn small color="error" @click="confirmDelete(item)">
                            <v-icon color="white">mdi-delete</v-icon>
                        </v-btn>
                    </template>
                </v-data-table>
            </v-card-text>
        </v-card>

        <!-- Add/Edit Category Dialog -->
        <v-dialog v-model="dialog" max-width="500px">
            <v-card>
                <v-card-title>
                    <span class="text-h5">{{ formTitle }}</span>
                </v-card-title>

                <v-card-text>
                    <v-container>
                        <v-row>
                            <v-col cols="12">
                                <v-text-field v-model="editedItem.name" label="Tên Danh Mục" required></v-text-field>
                            </v-col>
                            <v-col cols="12">
                                <v-textarea v-model="editedItem.description" label="Mô Tả"></v-textarea>
                            </v-col>
                            <v-col cols="12">
                                <v-select v-model="editedItem.type" :items="typeOptions" label="Loại" placeholder="Chọn loại danh mục" required></v-select>
                            </v-col>
                            <v-col cols="12">
                                <v-select v-model="editedItem.status" :items="statusOptions" label="Trạng Thái" required></v-select>
                            </v-col>
                        </v-row>
                    </v-container>
                </v-card-text>

                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDialog">Hủy</v-btn>
                    <v-btn color="primary" @click="saveCategory" :loading="loading" :disabled="loading">Lưu</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Delete Confirmation Dialog -->
        <v-dialog v-model="deleteDialog" max-width="400px">
            <v-card>
                <v-card-title class="text-h5">Xác nhận xóa danh mục</v-card-title>
                <v-card-text>Bạn có chắc chắn muốn xóa danh mục này không?</v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDeleteDialog">Hủy</v-btn>
                    <v-btn color="red" @click="deleteCategory">Xóa</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useCategoryStore } from '../../stores';

const loading = ref(false);
const search = ref('');
const notification = ref({ message: '', type: 'info' });
const itemsPerPage = 5;
const page = ref(1);
const dialog = ref(false);
const deleteDialog = ref(false);
const editedIndex = ref(-1);
const editedItem = ref({
    id: null,
    name: '',
    description: '',
    type: '',
    status: 'active'
});
const defaultItem = {
    id: null,
    name: '',
    description: '',
    type: '',
    status: 'active'
};

const store = useCategoryStore();

const headers = [
    { title: 'STT', align: 'center', sortable: false, key: 'id' },
    { title: 'Tên Danh Mục', align: 'start', sortable: true, key: 'name' },
    { title: 'Mô Tả', align: 'start', key: 'description' },
    { title: 'Loại', align: 'center', key: 'type' },
    { title: 'Trạng Thái', align: 'center', key: 'status' },
    { title: 'Hành Động', align: 'center', key: 'actions', sortable: false }
];

const statusOptions = [
    { title: 'Hoạt động', value: 'active' },
    { title: 'Không hoạt động', value: 'inactive' }
];

const typeOptions = [
    { title: 'Câu lạc bộ', value: 'club' },
    { title: 'Sự kiện', value: 'event' },
    { title: 'Tin tức', value: 'blog' }
];

const filteredCategories = computed(() => {
    return (store.categories || []).filter((category) =>
        category && category.name ? category.name.toLowerCase().includes(search.value.toLowerCase()) : false
    ).sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
});

// Fetch categories when component is mounted
onMounted(async () => {
    await store.fetchCategories();
});

const formTitle = computed(() => {
    return editedIndex.value === -1 ? 'Thêm Danh Mục' : 'Chỉnh Sửa Danh Mục';
});

const openAddDialog = () => {
    editedIndex.value = -1;
    editedItem.value = { ...defaultItem }; // Sử dụng spread operator để sao chép
    dialog.value = true;
};

const editCategory = (item) => {
    editedIndex.value = store.categories.indexOf(item);
    editedItem.value = { ...item }; // Sử dụng spread operator để sao chép
    dialog.value = true;
};

const closeDialog = () => {
    dialog.value = false;
    editedItem.value = { ...defaultItem }; // Reset form
    editedIndex.value = -1;
};

const saveCategory = async () => {
    loading.value = true;
    try {
        if (editedIndex.value > -1) {
            await store.updateCategory(editedItem.value.id, editedItem.value);
            Object.assign(store.categories[editedIndex.value], editedItem.value);
            showNotification('Danh mục đã được cập nhật thành công!', 'success');
        } else {
            const newCategory = await store.createCategory(editedItem.value);
            store.categories.push(newCategory);
            showNotification('Danh mục mới đã được thêm thành công!', 'success');
        }
    } catch (error) {
        showNotification('Có lỗi xảy ra khi lưu danh mục!', 'error');
    } finally {
        loading.value = false;
        closeDialog();
    }
};

const confirmDelete = (item) => {
    editedIndex.value = store.categories.indexOf(item);
    editedItem.value = { ...item }; // Sử dụng spread operator để sao chép
    deleteDialog.value = true;
};

const deleteCategory = async () => {
    await store.deleteCategory(editedItem.value.id);
    store.categories.splice(editedIndex.value, 1);
    closeDeleteDialog();
    showNotification('Danh mục đã được xóa thành công!', 'success');
};

const closeDeleteDialog = () => {
    deleteDialog.value = false;
    editedItem.value = { ...defaultItem }; // Reset form
    editedIndex.value = -1;
};

const showNotification = (message, type) => {
    notification.value = { message, type };
    setTimeout(() => {
        notification.value = { message: '', type: 'info' };
    }, 3000);
};
</script>

<style scoped>
.v-data-table ::v-deep th {
    font-weight: bold !important;
}
</style>