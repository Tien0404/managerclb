<template>
    <v-container fluid class="pa-0">
        <v-card class="elevation-2">
            <v-toolbar color="primary" dark>
                <v-toolbar-title>Quản Lý Sự Kiện</v-toolbar-title>
                <v-spacer></v-spacer>
            </v-toolbar>

            <v-card-text>
                <v-alert v-if="notification.message" :type="notification.type" :text="notification.message" class="mb-4" closable></v-alert>
                <v-row class="mb-4">
                    <v-col cols="12">
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
                    :items="filteredEvents"
                    :items-per-page="itemsPerPage"
                    :page.sync="page"
                    class="elevation-1"
                >
                    <template v-slot:item.index="{ item }">
                        {{ filteredEvents.indexOf(item) + 1 + (page.value - 1) * itemsPerPage }}
                    </template>

                    <template v-slot:item.status="{ item }">
                        <v-chip
                            :color="getStatusColor(item.status)"
                            small
                        >
                            {{ getStatusText(item.status) }}
                        </v-chip>
                    </template>

                    <template v-slot:item.start_date="{ item }">
                        {{ formatDate(item.start_date) }}
                    </template>

                    <template v-slot:item.end_date="{ item }">
                        {{ formatDate(item.end_date) }}
                    </template>

                    <template v-slot:item.actions="{ item }">
                        <v-btn small color="primary" class="mr-2" @click="editEvent(item)">
                            <v-icon small>mdi-pencil</v-icon>
                        </v-btn>
                        <v-btn small color="error" @click="confirmDelete(item)">
                            <v-icon small>mdi-delete</v-icon>
                        </v-btn>
                    </template>
                </v-data-table>
            </v-card-text>
        </v-card>

        <!-- Add/Edit Event Dialog -->
        <v-dialog v-model="dialog" max-width="600px">
            <v-card>
                <v-card-title>
                    <span class="text-h5">Cập Nhật Trạng Thái</span>
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
                    <v-btn color="primary" @click="saveEvent" :loading="loading" :disabled="loading">Lưu</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Delete Confirmation Dialog -->
        <v-dialog v-model="deleteDialog" max-width="400px">
            <v-card>
                <v-card-title class="text-h5">Xác nhận xóa sự kiện</v-card-title>
                <v-card-text>Bạn có chắc chắn muốn xóa sự kiện này không?</v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn text @click="closeDeleteDialog">Hủy</v-btn>
                    <v-btn color="error" @click="deleteEvent">Xóa</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useEventStore, useCategoryStore, useClubStore } from '../../stores';

const loading = ref(false);
const search = ref('');
const notification = ref({ message: '', type: 'info' });
const itemsPerPage = 5;
const page = ref(1);
const dialog = ref(false);
const deleteDialog = ref(false);
const startDateMenu = ref(false);
const endDateMenu = ref(false);
const editedIndex = ref(-1);
const editedItem = ref({
    status: 'active',
});
const defaultItem = {
    status: 'active',
};

const store = useEventStore();
const categoryStore = useCategoryStore();
const clubStore = useClubStore();

const headers = [
    { title: 'STT', align: 'center', sortable: false, key: 'id' },
    { title: 'Tên sự kiện', align: 'start', sortable: true, key: 'name' },
    { title: 'Club', align: 'start', sortable: true, key: 'club_name' },
    { title: 'Trạng Thái', align: 'center', key: 'status' },
    { title: 'Hành Động', align: 'center', key: 'actions', sortable: false }
];

const statusOptions = [
    { title: 'Hoạt động', value: 'active' },
    { title: 'Không hoạt động', value: 'inactive' },
    { title: 'Đã kết thúc', value: 'completed' },
    { title: 'Đã hủy', value: 'cancelled' }
];

const filteredEvents = computed(() => {
    if (!Array.isArray(store.events)) {
        return [];
    }
    const events = store.events
        .filter(event => event && typeof event === 'object')
        .map(event => ({
            ...event,
            club_name: event.club_id && clubStore.clubs ? 
                (clubStore.clubs.find(club => club && club.id === event.club_id)?.name || 'N/A') : 'N/A'
        }))
        .filter(event => {
            if (!search.value) return true;
            return event.title && event.title.toLowerCase().includes(search.value.toLowerCase());
        });
    return events;
});

onMounted(async () => {
    await Promise.all([store.fetchEvents(), clubStore.fetchClubs()]);
});

const getStatusColor = (status) => {
    switch (status) {
        case 'active':
            return 'success';
        case 'inactive':
            return 'error';
        case 'completed':
            return 'info';
        case 'cancelled':
            return 'warning';
        default:
            return 'grey';
    }
};

const getStatusText = (status) => {
    switch (status) {
        case 'active':
            return 'Hoạt động';
        case 'inactive':
            return 'Không hoạt động';
        case 'completed':
            return 'Đã kết thúc';
        case 'cancelled':
            return 'Đã hủy';
        default:
            return 'Không xác định';
    }
};

const editEvent = (item) => {
    editedIndex.value = store.events.indexOf(item);
    editedItem.value = { ...item };
    dialog.value = true;
};

const closeDialog = () => {
    dialog.value = false;
    editedItem.value = { status: 'active' };
    editedIndex.value = -1;
};

const saveEvent = async () => {
    if (!editedItem.value.id || !editedItem.value.status) {
        showNotification('Vui lòng điền đầy đủ thông tin!', 'error');
        return;
    }

    loading.value = true;
    try {
        await store.updateEvent(editedItem.value.id, {
            status: editedItem.value.status
        });
        await store.fetchEvents();
        showNotification('Trạng thái sự kiện đã được cập nhật thành công!', 'success');
        closeDialog();
    } catch (error) {
        const errorMessage = error.response?.data?.message || 'Có lỗi xảy ra khi cập nhật trạng thái!';
        showNotification(errorMessage, 'error');
        console.error('Error updating event:', error);
    } finally {
        loading.value = false;
    }
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