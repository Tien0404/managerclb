<template>
    <v-container fluid class="pa-0">
        <v-card class="elevation-2">
            <v-toolbar color="primary" dark>
                <v-toolbar-title>Quản Lý Phản Hồi</v-toolbar-title>
                <v-spacer></v-spacer>
            </v-toolbar>

            <v-card-text>
                <v-alert v-if="notification.message" :type="notification.type" :text="notification.message" class="mb-4" closable></v-alert>

                <v-row class="mb-4">
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
                    :items="filteredFeedbacks"
                    :items-per-page="itemsPerPage"
                    :page.sync="page"
                    class="elevation-1"
                >
                    <template v-slot:item.index="{ item }">
                        {{ filteredFeedbacks.indexOf(item) + 1 + (page.value - 1) * itemsPerPage }}
                    </template>

                    <template v-slot:item.status="{ item }">
                        <v-chip
                            :color="item.status === 'resolved' ? 'success' : 'warning'"
                            small
                        >
                            {{ item.status === 'resolved' ? 'Đã xử lý' : 'Chưa xử lý' }}
                        </v-chip>
                    </template>

                    <template v-slot:item.actions="{ item }">
                        <v-btn small color="primary" class="mr-2" @click="editFeedback(item)">
                            <v-icon small>mdi-pencil</v-icon>
                        </v-btn>
                        <v-btn small color="error" @click="confirmDelete(item)">
                            <v-icon small>mdi-delete</v-icon>
                        </v-btn>
                    </template>
                </v-data-table>
            </v-card-text>
        </v-card>

        <!-- Add/Edit Feedback Dialog -->
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
                                    v-model="editedItem.status"
                                    :items="statusOptions"
                                    label="Trạng Thái"
                                    required
                                ></v-select>
                            </v-col>
                        </v-row>
                    </v-container>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDialog">Hủy</v-btn>
                    <v-btn color="primary" @click="saveFeedback" :loading="loading" :disabled="loading">Lưu</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Delete Confirmation Dialog -->
        <v-dialog v-model="deleteDialog" max-width="400px">
            <v-card>
                <v-card-title class="text-h5">Xác nhận xóa phản hồi</v-card-title>
                <v-card-text>Bạn có chắc chắn muốn xóa phản hồi này không?</v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDeleteDialog">Hủy</v-btn>
                    <v-btn color="error" @click="deleteFeedback">Xóa</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useFeedbackStore } from '../../stores';

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
    title: '',
    content: '',
    contact_email: '',
    status: 'pending',
    user_id: null
});
const defaultItem = {
    id: null,
    title: '',
    content: '',
    contact_email: '',
    status: 'pending',
    user_id: null
};

const store = useFeedbackStore();

const headers = [
    { title: 'STT', align: 'center', sortable: false, key: 'id' },
    { title: 'Tiêu đề', align: 'start', sortable: true, key: 'name' },
    { title: 'Nội dung', align: 'start', key: 'comment' },
    { title: 'Email liên hệ', align: 'start', key: 'email' },
    { title: 'Trạng Thái', align: 'center', key: 'status' },
    { title: 'Hành Động', align: 'center', key: 'actions', sortable: false }
];

const statusOptions = [
    { title: 'Đã xử lý', value: 'resolved' },
    { title: 'Chưa xử lý', value: 'pending' }
];

const filteredFeedbacks = computed(() => {
    if (!Array.isArray(store.feedbacks)) {
        return [];
    }
    const feedbacks = store.feedbacks
        .filter(feedback => feedback && typeof feedback === 'object')
        .map(feedback => ({
            ...feedback,
            created_at: feedback.created_at ? new Date(feedback.created_at).toLocaleDateString('vi-VN') : 'N/A'
        }))
        .filter(feedback => {
            if (!search.value) return true;
            return feedback.title && feedback.title.toLowerCase().includes(search.value.toLowerCase());
        });
    return feedbacks;
});

const formTitle = computed(() => {
    return editedIndex.value === -1 ? 'Thêm Phản Hồi' : 'Chỉnh Sửa Phản Hồi';
});

// Fetch feedbacks when component is mounted
onMounted(async () => {
    await store.fetchFeedbacks();
    const userStr = localStorage.getItem('user');
    const user = userStr ? JSON.parse(userStr) : null;
    editedItem.value.user_id = user?.id;
});

const editFeedback = (item) => {
    editedIndex.value = store.feedbacks.indexOf(item);
    editedItem.value = { ...item };
    dialog.value = true;
};

const closeDialog = () => {
    dialog.value = false;
    editedItem.value = { ...defaultItem };
    editedIndex.value = -1;
};

const saveFeedback = async () => {
    loading.value = true;
    try {
        await store.updateFeedback(editedItem.value.id, {
            status: editedItem.value.status
        });
        showNotification('Phản hồi đã được cập nhật thành công!', 'success');
        closeDialog();
    } catch (error) {
        showNotification('Có lỗi xảy ra khi lưu phản hồi!', 'error');
    } finally {
        loading.value = false;
    }
};

const confirmDelete = (item) => {
    editedIndex.value = store.feedbacks.indexOf(item);
    editedItem.value = { ...item };
    deleteDialog.value = true;
};

const deleteFeedback = async () => {
    try {
        await store.deleteFeedback(editedItem.value.id);
        store.feedbacks.splice(editedIndex.value, 1);
        closeDeleteDialog();
        showNotification('Phản hồi đã được xóa thành công!', 'success');
    } catch (error) {
        showNotification('Có lỗi xảy ra khi xóa phản hồi!', 'error');
    }
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