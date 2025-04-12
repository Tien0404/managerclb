<template>
    <v-container fluid class="pa-0">
        <v-card class="elevation-2">
            <v-toolbar color="primary" dark>
                <v-toolbar-title>Quản Lý Club</v-toolbar-title>
                <v-spacer></v-spacer>
            </v-toolbar>

            <v-card-text>
                <v-alert v-if="notification.message" :type="notification.type" :text="notification.message" class="mb-4" closable></v-alert>

                <v-row class="mb-4">
                    <v-col cols="12" sm="4">
                        <v-btn color="primary" @click="openAddDialog">Thêm Club</v-btn>
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
                    :items="filteredClubs"
                    :items-per-page="itemsPerPage"
                    :page.sync="page"
                    class="elevation-1"
                >
                    <template v-slot:item.index="{ item }">
                        {{ filteredClubs.indexOf(item) + 1 + (page.value - 1) * itemsPerPage }}
                    </template>

                    <template v-slot:item.actions="{ item }">
                        <v-btn small color="primary" @click="editClub(item)">
                            <v-icon color="white">mdi-pencil</v-icon>
                        </v-btn>
                        <v-btn small color="error" @click="confirmDelete(item)">
                            <v-icon color="white">mdi-delete</v-icon>
                        </v-btn>
                    </template>
                    <template v-slot:item.status="{ item }">
                        <v-chip :color="item.status === 'active' ? 'success' : 'error'" small>
                            {{ item.status === 'active' ? 'Hoạt động' : 'Không hoạt động' }}
                        </v-chip>
                    </template>
                </v-data-table>
            </v-card-text>
        </v-card>

        <!-- Add/Edit Club Dialog -->
        <v-dialog v-model="dialog" max-width="500px">
            <v-card>
                <v-card-title>
                    <span class="text-h5">{{ formTitle }}</span>
                </v-card-title>
                <v-card-text>
                    <v-container>
                        <v-row>
                            <v-col cols="12">
                                <v-select
                                    v-model="editedItem.category_id"
                                    :items="clubCategories"
                                    item-title="name"
                                    item-value="id"
                                    label="Danh mục"
                                    required
                                ></v-select>
                                <v-text-field v-model="editedItem.name" label="Tên Club" required></v-text-field>
                                <v-text-field v-model="editedItem.contact_email" label="Email liên hệ" required></v-text-field>
                                <v-select
                                    v-if="editedIndex > -1"
                                    v-model="editedItem.status"
                                    :items="statusOptions"
                                    item-title="title"
                                    item-value="value"
                                    label="Trạng thái"
                                    required
                                ></v-select>
                            </v-col>
                        </v-row>
                    </v-container>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDialog">Hủy</v-btn>
                    <v-btn color="primary" @click="saveClub" :loading="loading" :disabled="loading">Lưu</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Delete Confirmation Dialog -->
        <v-dialog v-model="deleteDialog" max-width="400px">
            <v-card>
                <v-card-title class="text-h5">Xác nhận xóa club</v-card-title>
                <v-card-text>Bạn có chắc chắn muốn xóa club này không?</v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDeleteDialog">Hủy</v-btn>
                    <v-btn color="red" @click="deleteClub">Xóa</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useClubStore, useCategoryStore } from '../../stores';

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
    category_id: null,
    name: '',
    contact_email: ''
});
const defaultItem = {
    id: null,
    category_id: null,
    name: '',
    contact_email: ''
};

const store = useClubStore();
const categoryStore = useCategoryStore();

const headers = [
    { title: 'STT', align: 'center', sortable: false, key: 'id' },
    { title: 'Tên Club', align: 'start', sortable: true, key: 'name' },
    { title: 'Email liên hệ', align: 'start', key: 'contact_email' },
    { title: 'Trạng Thái', align: 'start', key: 'status' },
    { title: 'Hành Động', align: 'center', key: 'actions', sortable: false }
];

const statusOptions = [
    { title: 'Hoạt động', value: 'active' },
    { title: 'Không hoạt động', value: 'pending' }
];

const clubCategories = computed(() => {
    return (categoryStore.categories || []).filter((category) => category && category.type === 'club') || [];
});

const filteredClubs = computed(() => {
    return (store.clubs || []).filter((club) => club && club.name && club.name.toLowerCase().includes((search.value || '').toLowerCase()));
});

// Fetch clubs and categories when component is mounted
onMounted(async () => {
    await Promise.all([store.fetchClubs(), categoryStore.fetchCategories()]);
    const userStr = localStorage.getItem('user');
    const user = userStr ? JSON.parse(userStr) : null;
    editedItem.value.user_id = user?.id;
    console.log('User:', editedItem.value.user_id);
});

const formTitle = computed(() => {
    return editedIndex.value === -1 ? 'Thêm Club' : 'Chỉnh Sửa Club';
});

const openAddDialog = () => {
    editedIndex.value = -1;
    editedItem.value = { ...defaultItem };
    dialog.value = true;
};

const editClub = (item) => {
    editedIndex.value = store.clubs.indexOf(item);
    editedItem.value = { ...item };
    dialog.value = true;
};

const closeDialog = () => {
    dialog.value = false;
    editedItem.value = { ...defaultItem };
    editedIndex.value = -1;
};

const saveClub = async () => {
    loading.value = true;
    try {
        const payload = {
            user_id: editedItem.value.user_id,
            category_id: editedItem.value.category_id,
            name: editedItem.value.name,
            contact_email: editedItem.value.contact_email
        };

        console.log('Dữ liệu gửi đến API:', payload);

        if (editedIndex.value > -1) {
            payload.status = editedItem.value.status;
            await store.updateClub(editedItem.value.id, payload);
            await store.fetchClubs();
            showNotification('Trạng thái club đã được cập nhật thành công!', 'success');
            closeDialog();
        } else {
            await store.createClub(payload);
            await store.fetchClubs();
            showNotification('Club đã được tạo thành công!', 'success');
            closeDialog();
        }
    } catch (error) {
        console.error('Chi tiết lỗi:', {
            response: error.response?.data,
            message: error.message,
            stack: error.stack
        });
        let errorMessage = editedIndex.value > -1 ? 'Có lỗi xảy ra khi cập nhật trạng thái!' : 'Có lỗi xảy ra khi tạo club!';
        if (error.response?.data?.errors) {
            const errors = error.response.data.errors;
            errorMessage = Object.values(errors).flat().join('\n');
        } else if (error.response?.data?.message) {
            errorMessage = error.response.data.message;
        } else if (error.message) {
            errorMessage = error.message;
        }
        showNotification(errorMessage, 'error');
    } finally {
        loading.value = false;
    }
};

const confirmDelete = (item) => {
    editedIndex.value = store.clubs.indexOf(item);
    editedItem.value = { ...item };
    deleteDialog.value = true;
};

const deleteClub = async () => {
    await store.deleteClub(editedItem.value.id);
    await store.fetchClubs();
    closeDeleteDialog();
    showNotification('Club đã được xóa thành công!', 'success');
};

const closeDeleteDialog = () => {
    deleteDialog.value = false;
    editedItem.value = { ...defaultItem };
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
