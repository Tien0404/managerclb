<template>
  <v-container fluid class="pa-0">
    <v-card class="elevation-2">
      <v-toolbar color="primary" dark>
        <v-toolbar-title>Quản Lý Blog</v-toolbar-title>
        <v-spacer></v-spacer>
      </v-toolbar>

      <v-card-text>
        <v-alert v-if="notification.message" :type="notification.type" :text="notification.message" class="mb-4" closable></v-alert>

        <v-row class="mb-4">
          <v-col cols="12">
            <v-select
              v-model="selectedCategory"
              :items="categoryOptions"
              label="Danh Mục"
              item-title="name"
              item-value="id"
              variant="outlined"
              density="compact"
              class="category-select"
              @update:model-value="applyFilter"
            ></v-select>
          </v-col>
        </v-row>

        <v-data-table
          :headers="headers"
          :items="filteredBlogs"
          :items-per-page="itemsPerPage"
          :page.sync="page"
          class="elevation-1"
        >
          <template v-slot:item.index="{ item }">
            {{ filteredBlogs.indexOf(item) + 1 + (page.value - 1) * itemsPerPage }}
          </template>

          <template v-slot:item.status="{ item }">
            <v-chip :color="item.status === 'active' ? 'success' : 'error'" small>
              {{ item.status === 'active' ? 'Hiện' : 'Ẩn' }}
            </v-chip>
          </template>

          <template v-slot:item.actions="{ item }">
            <v-btn small color="primary" class="mr-2" @click="editBlog(item)">
              <v-icon color="white">mdi-pencil</v-icon>
            </v-btn>
            <v-btn small color="error" @click="confirmDelete(item)">
              <v-icon color="white">mdi-delete</v-icon>
            </v-btn>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>

    <!-- Add/Edit Blog Dialog -->
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
          <v-btn color="primary" @click="saveBlog" :loading="loading" :disabled="loading">Lưu</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Delete Confirmation Dialog -->
    <v-dialog v-model="deleteDialog" max-width="400px">
      <v-card>
        <v-card-title class="text-h5">Xác nhận xóa blog</v-card-title>
        <v-card-text>Bạn có chắc chắn muốn xóa blog này không?</v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn text @click="closeDeleteDialog">Hủy</v-btn>
          <v-btn color="red" @click="deleteBlog">Xóa</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useBlogStore, useClubStore, useCategoryStore } from '../../stores';

const notification = ref({ message: '', type: 'info' });
const itemsPerPage = 5;
const page = ref(1);
const loading = ref(false);
const dialog = ref(false);
const deleteDialog = ref(false);
const editedIndex = ref(-1);
const statusOptions = [
    { title: 'Hiện', value: 'active' },
    { title: 'Ẩn', value: 'inactive' }
];

const editedItem = ref({
    status: 'active'
});
const defaultItem = {
    status: 'active'
};

const store = useBlogStore();
const clubStore = useClubStore();
const categoryStore = useCategoryStore();

const headers = [
    { title: 'STT', align: 'center', key: 'id' },
    { title: 'Tiêu Đề', align: 'start', key: 'title' },
    { title: 'Club', align: 'start', key: 'club_name' },
    { title: 'Danh Mục', align: 'center', key: 'category_name' },
    { title: 'Trạng Thái', align: 'center', key: 'status' },
    { title: 'Hành Động', align: 'center', key: 'actions' }
];

const selectedCategory = ref(null);

const categoryOptions = computed(() => {
  return (categoryStore.categories || []).filter(category => category && category.type === 'blog').map(category => ({
    id: category.id,
    name: category.name
  }));
});

const applyFilter = () => {
  // Filtering is handled by the computed property
};

const filteredBlogs = computed(() => {
  return store.blogs
    .filter(blog => blog && typeof blog === 'object')
    .map(blog => ({
      ...blog,
      club_name: blog.club_id ? (clubStore.clubs.find(club => club?.id === blog.club_id)?.name || 'N/A') : 'N/A',
      category_name: blog.category_id ? (categoryStore.categories.find(category => category?.id === blog.category_id)?.name || 'N/A') : 'N/A'
    }))
    .filter(blog => !selectedCategory.value || blog.category_id === selectedCategory.value);
});

onMounted(async () => {
    await Promise.all([
        store.fetchBlogs(),
        clubStore.fetchClubs(),
        categoryStore.fetchCategories()
    ]);
});

const formTitle = computed(() => editedIndex.value === -1 ? 'Thêm Blog' : 'Chỉnh Sửa Blog');

const editBlog = (item) => {
    editedIndex.value = store.blogs.indexOf(item);
    editedItem.value = { ...item };
    dialog.value = true;
};

const closeDialog = () => {
    dialog.value = false;
    editedItem.value = { ...defaultItem };
    editedIndex.value = -1;
};

const saveBlog = async () => {
    loading.value = true;
    try {
        await store.updateBlog(editedItem.value.id, editedItem.value);
        showNotification('Blog đã được cập nhật thành công!', 'success');
        closeDialog();
    } catch (error) {
        showNotification('Có lỗi xảy ra khi lưu blog!', 'error');
    } finally {
        loading.value = false;
    }
};

const confirmDelete = (item) => {
    editedIndex.value = store.blogs.indexOf(item);
    editedItem.value = { ...item };
    deleteDialog.value = true;
};

const deleteBlog = async () => {
    await store.deleteBlog(editedItem.value.id);
    store.blogs.splice(editedIndex.value, 1);
    closeDeleteDialog();
    showNotification('Blog đã được xóa thành công!', 'success');
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

.category-select {
  min-width: 200px;
}
</style>