<template>
    <v-container fluid class="pa-0">
        <v-card class="elevation-2">
            <v-toolbar color="primary" dark>
                <v-toolbar-title>Quản Lý Người Dùng</v-toolbar-title>
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
                            @input="applyFilter"
                        ></v-text-field>
                    </v-col>
                </v-row>

                <v-data-table
                    :headers="headers"
                    :items="filteredUsers"
                    :items-per-page="itemsPerPage"
                    :page.sync="page"
                    class="elevation-1"
                >
                    <template v-slot:item.index="{ item }">
                        {{ filteredUsers.indexOf(item) + 1 + (page.value - 1) * itemsPerPage }}
                    </template>

                    <template v-slot:item.email_verified="{ item }">
                        <v-chip :color="item.email_verified ? 'success' : 'warning'" :text-color="'white'" small>
                            {{ item.email_verified ? 'Đã xác thực' : 'Chưa xác thực' }}
                        </v-chip>
                    </template>

                    <template v-slot:item.role="{ item }">
                        <v-chip :color="getRoleColor(item.role)" text-color="white" small>
                            {{ getRoleLabel(item.role) }}
                        </v-chip>
                    </template>

                    <template v-slot:item.created_at="{ item }">
                        {{ formatDate(item.created_at) }}
                    </template>
                    <template v-slot:item.actions="{ item }">
                        <v-btn small color="primary" class="mr-2" @click="editUser(item)">Sửa</v-btn>
                        <v-btn small color="error" @click="confirmDelete(item)">Xóa</v-btn>
                    </template>
                </v-data-table>
            </v-card-text>
        </v-card>

        <!-- Add/Edit User Dialog -->
        <v-dialog v-model="dialog" max-width="500px">
            <v-card>
                <v-card-title>
                    <span class="text-h5">{{ formTitle }}</span>
                </v-card-title>

                <v-card-text>
                    <v-container>
                        <v-row>
                            <v-col cols="12" sm="6">
                                <v-text-field v-model="editedItem.username" label="Tên đăng nhập" required></v-text-field>
                            </v-col>
                            <v-col cols="12" sm="6">
                                <v-text-field v-model="editedItem.email" label="Email" type="email" required></v-text-field>
                            </v-col>
                            <v-col cols="12" sm="6">
                                <v-text-field v-model="editedItem.phone" label="Số điện thoại"></v-text-field>
                            </v-col>
                            <v-col cols="12" v-if="editedIndex === -1">
                                <v-text-field v-model="editedItem.password" label="Mật khẩu" type="password" required></v-text-field>
                            </v-col>
                        </v-row>
                    </v-container>
                </v-card-text>

                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="blue darken-1" text @click="closeDialog">Hủy</v-btn>
                    <v-btn color="blue darken-1" text @click="saveUser">Lưu</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Delete Confirmation Dialog -->
        <v-dialog v-model="deleteDialog" max-width="400px">
            <v-card>
                <v-card-title class="text-h5">Xác nhận xóa người dùng</v-card-title>
                <v-card-text>Bạn có chắc chắn muốn xóa người dùng này không?</v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="blue darken-1" text @click="closeDeleteDialog">Hủy</v-btn>
                    <v-btn color="red darken-1" text @click="deleteUser">Xóa</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useUserStore } from '../../stores';

const search = ref('');
const notification = ref({ message: '', type: 'info' });
const itemsPerPage = 5;
const page = ref(1);
const dialog = ref(false);
const deleteDialog = ref(false);
const editedIndex = ref(-1);

const defaultItem = {
    id: null,
    username: '',
    email: '',
    phone: '',
    role: 'User',
    email_verified: 0,
    password: ''
};

const editedItem = ref({ ...defaultItem });

const store = useUserStore();

const headers = [
    { title: 'STT', align: 'center', sortable: false, key: 'id' },
    { title: 'Tên đăng nhập', align: 'start', sortable: true, key: 'username' },
    { title: 'Email', align: 'start', sortable: true, key: 'email' },
    { title: 'Vai trò', align: 'center', key: 'role' },
    { title: 'Trạng thái xác thực', align: 'center', key: 'email_verified' },
    { title: 'Hành động', align: 'center', key: 'actions', sortable: false }
];

const verificationOptions = [
    { title: 'Đã xác thực', value: 1 },
    { title: 'Chưa xác thực', value: 0 }
];

const roleOptions = [
    { title: 'Quản trị viên', value: 'Admin' },
    { title: 'Người dùng', value: 'User' },
    { title: 'Nhân viên', value: 'Staff' }
];

const genderOptions = [
    { title: 'Nam', value: 'male' },
    { title: 'Nữ', value: 'female' },
    { title: 'Khác', value: 'other' }
];

const getRoleColor = (role) => {
    const colors = {
        Admin: 'deep-purple',
        User: 'blue',
        Staff: 'green'
    };
    return colors[role] || 'grey';
};

const getRoleLabel = (role) => {
    const labels = {
        Admin: 'Quản trị viên',
        User: 'Người dùng',
        Staff: 'Nhân viên'
    };
    return labels[role] || role;
};

const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    }).format(date);
};

const filteredUsers = computed(() => {
    return store.users.filter(
        (user) =>
            user.username.toLowerCase().includes(search.value.toLowerCase()) ||
            user.email.toLowerCase().includes(search.value.toLowerCase()) ||
            user.phone.toLowerCase().includes(search.value.toLowerCase())
    );
});

onMounted(async () => {
    await store.fetchUsers();
});

const formTitle = computed(() => {
    return editedIndex.value === -1 ? 'Thêm Người Dùng' : 'Chỉnh Sửa Người Dùng';
});

const applyFilter = () => {
    // Filtering is handled by the computed property
};

const editUser = (item) => {
    editedIndex.value = store.users.indexOf(item);
    editedItem.value = { ...item };
    delete editedItem.value.password; // Không hiện password khi chỉnh sửa
    dialog.value = true;
};

const closeDialog = () => {
    dialog.value = false;
    editedItem.value = { ...defaultItem };
    editedIndex.value = -1;
};

const saveUser = async () => {
    if (editedIndex.value > -1) {
        await store.updateUser(editedItem.value.id, editedItem.value);
        await store.fetchUsers();
        showNotification('Người dùng đã được cập nhật thành công!', 'success');
    } else {
        const newUser = await store.createUser(editedItem.value);
        await store.fetchUsers();
        showNotification('Người dùng mới đã được thêm thành công!', 'success');
    }
    closeDialog();
};

const confirmDelete = (item) => {
    editedIndex.value = store.users.indexOf(item);
    editedItem.value = { ...item };
    deleteDialog.value = true;
};

const deleteUser = async () => {
    await store.deleteUser(editedItem.value.id);
    await store.fetchUsers();
    closeDeleteDialog();
    showNotification('Người dùng đã được xóa thành công!', 'success');
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
