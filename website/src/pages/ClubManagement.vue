<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
    <div
      class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 relative"
      data-aos="fade-in"
    >
      <!-- Decorative Elements -->
      <div
        class="absolute top-0 left-0 w-64 h-64 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob"
      ></div>
      <div
        class="absolute top-0 right-0 w-64 h-64 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000"
      ></div>
      <div
        class="absolute -bottom-8 left-20 w-64 h-64 bg-pink-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000"
      ></div>

      <!-- Header Section -->
      <div class="container mx-auto px-4 py-8 relative">
        <div
          class="flex justify-between items-center mb-6"
          data-aos="fade-down"
          data-aos-delay="100"
        >
          <div class="relative">
            <h1
              class="text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-primary to-accent mb-2 animate-gradient"
            >
              Câu lạc bộ của tôi
            </h1>
            <p class="text-gray-600 text-lg animate-fade-in relative">
              Quản lý danh sách các CLB mà bạn đã
              <span
                class="font-medium text-primary relative inline-block after:content-[''] after:absolute after:bottom-0 after:left-0 after:w-full after:h-0.5 after:bg-primary after:transform after:scale-x-0 after:transition-transform after:duration-300 hover:after:scale-x-100"
                >Tạo</span
              >
              hoặc đã
              <span
                class="font-medium text-accent relative inline-block after:content-[''] after:absolute after:bottom-0 after:left-0 after:w-full after:h-0.5 after:bg-accent after:transform after:scale-x-0 after:transition-transform after:duration-300 hover:after:scale-x-100"
                >Tham gia</span
              >
            </p>
            <!-- Decorative Line -->
            <div
              class="absolute -bottom-4 left-0 w-24 h-1 bg-gradient-to-r from-primary to-accent rounded-full"
            ></div>
          </div>
          <!-- Create Club Button with Enhanced Animation -->
          <button
            @click="openCreateDialog"
            class="group px-6 py-3 bg-gradient-to-r from-primary to-accent text-white rounded-lg shadow-lg hover:shadow-2xl transform hover:scale-105 transition-all duration-300 flex items-center gap-3 relative overflow-hidden"
          >
            <div
              class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"
            ></div>
            <PlusIcon
              class="w-6 h-6 transition-transform group-hover:rotate-180 duration-500"
            />
            <span class="relative z-10 font-medium">Tạo câu lạc bộ</span>
          </button>
        </div>

        <div class="flex gap-8">
          <!-- Enhanced Sidebar with Animation -->
          <div
            class="w-64 flex-shrink-0 space-y-4"
            data-aos="fade-right"
            data-aos-delay="200"
          >
            <div
              class="bg-white rounded-xl border shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden group"
            >
              <div
                class="p-4 bg-gradient-to-r from-blue-50 to-indigo-50 border-b relative"
              >
                <span class="font-medium text-primary">Quản lý Câu lạc bộ</span>
                <div
                  class="absolute bottom-0 left-0 w-full h-0.5 bg-gradient-to-r from-primary to-accent transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300"
                ></div>
              </div>
              <!-- Add some menu items -->
              <div class="p-4 space-y-2">
                <div
                  class="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer group"
                >
                  <div
                    class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center group-hover:bg-primary/20 transition-colors"
                  >
                    <UserCircleIcon class="w-5 h-5 text-primary" />
                  </div>
                  <span class="text-gray-700">Thành viên</span>
                </div>
                <div
                  class="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer group"
                >
                  <div
                    class="w-8 h-8 rounded-full bg-accent/10 flex items-center justify-center group-hover:bg-accent/20 transition-colors"
                  >
                    <BellIcon class="w-5 h-5 text-accent" />
                  </div>
                  <span class="text-gray-700">Thông báo</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Enhanced Empty State -->
          <div class="flex-1" data-aos="fade-up" data-aos-delay="300">
            <!-- Loading State -->
            <div v-if="loading" class="flex justify-center items-center py-12">
              <div
                class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"
              ></div>
            </div>

            <!-- Error State -->
            <div
              v-else-if="error"
              class="bg-red-50 border border-red-200 rounded-xl p-6 text-center"
            >
              <p class="text-red-600">{{ error }}</p>
              <button
                @click="fetchUserClubs"
                class="mt-4 px-4 py-2 text-sm text-red-600 border border-red-300 rounded-lg hover:bg-red-50"
              >
                Thử lại
              </button>
            </div>

            <!-- Empty State -->
            <div
              v-else-if="!userClubs.length"
              class="bg-white rounded-xl border p-12 text-center space-y-6 relative overflow-hidden group hover:shadow-xl transition-all duration-300"
            >
              <!-- Decorative Background -->
              <div
                class="absolute inset-0 bg-gradient-to-br from-gray-50 to-blue-50 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
              ></div>

              <!-- Content -->
              <div class="relative z-10">
                <div
                  class="w-40 h-40 mx-auto mb-8 transform group-hover:scale-110 transition-transform duration-500"
                >
                  <img
                    src="/placeholder-empty.svg"
                    alt="No clubs"
                    class="w-full h-full filter drop-shadow-xl"
                  />
                </div>
                <h3 class="text-2xl font-semibold text-gray-800 mb-4">
                  Chưa có câu lạc bộ nào
                </h3>
                <p class="text-gray-600 text-lg max-w-md mx-auto mb-8">
                  Bạn chưa tham gia hoặc tạo câu lạc bộ nào. Hãy bắt đầu bằng
                  cách tạo câu lạc bộ mới!
                </p>
                <button
                  @click="openCreateDialog"
                  class="group inline-flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-primary to-accent text-white rounded-lg shadow-lg hover:shadow-2xl transform hover:scale-105 transition-all duration-300 relative overflow-hidden"
                >
                  <div
                    class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"
                  ></div>
                  <PlusIcon
                    class="w-6 h-6 transition-transform group-hover:rotate-180 duration-500"
                  />
                  <span class="relative z-10 font-medium"
                    >Tạo câu lạc bộ mới</span
                  >
                </button>
              </div>

              <!-- Decorative Circles -->
              <div
                class="absolute -left-16 -top-16 w-64 h-64 bg-primary/5 rounded-full"
              ></div>
              <div
                class="absolute -right-16 -bottom-16 w-64 h-64 bg-accent/5 rounded-full"
              ></div>
            </div>

            <!-- Enhanced Club Cards List -->
            <div v-else class="space-y-6">
              <div
                v-for="(club, index) in userClubs"
                :key="club.id"
                class="bg-white rounded-xl border shadow-lg hover:shadow-2xl transition-all duration-500 transform hover:-translate-y-1 group"
                :data-aos="index % 2 === 0 ? 'fade-left' : 'fade-right'"
                :data-aos-delay="300"
              >
                <div
                  v-if="club.status === 'pending'"
                  class="block cursor-not-allowed"
                >
                  <div class="flex p-6 relative overflow-hidden opacity-75">
                    <!-- Background Gradient -->
                    <div
                      class="absolute inset-0 bg-gradient-to-br from-gray-50 to-blue-50 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    ></div>

                    <!-- Club Image with Enhanced Hover Effect -->
                    <div
                      class="relative w-80 h-48 rounded-xl overflow-hidden shadow-lg group-hover:shadow-xl transition-all duration-500"
                    >
                      <img
                        :src="club.image"
                        :alt="club.name"
                        class="w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-110 filter grayscale"
                      />
                      <div
                        class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                      ></div>
                    </div>

                    <!-- Club Details with Enhanced Animations -->
                    <div class="flex-1 ml-8 relative z-10">
                      <div class="flex flex-col h-full">
                        <!-- Pending Status Badge -->
                        <div class="flex items-center gap-2 mb-2">
                          <span
                            class="px-4 py-1.5 rounded-full text-sm font-medium bg-yellow-100 text-yellow-800 flex items-center gap-2"
                          >
                            <LockClosedIcon class="w-4 h-4" />
                            Đang chờ phê duyệt
                          </span>
                        </div>

                        <!-- Enhanced Club Name -->
                        <h3
                          class="text-2xl font-bold text-gray-500 transform group-hover:scale-105 transition-transform duration-300 truncate"
                        >
                          {{ club.name }}
                        </h3>

                        <!-- Enhanced Description -->
                        <p
                          class="text-gray-500 text-lg leading-relaxed opacity-90 group-hover:opacity-100 transition-all duration-300 mb-6 line-clamp-2"
                        >
                          {{ club.description }}
                        </p>

                        <!-- Enhanced Action Button -->
                        <div class="flex items-center space-x-3">
                          <button
                            disabled
                            class="group px-6 py-3 bg-gray-300 text-gray-600 rounded-lg shadow-lg cursor-not-allowed flex items-center gap-2"
                          >
                            <LockClosedIcon class="w-5 h-5" />
                            <span class="relative z-10 font-medium"
                              >Chờ phê duyệt</span
                            >
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <router-link
                  v-else
                  :to="`/club/${club.id}/dashboard`"
                  class="block"
                >
                  <div class="flex p-6 relative overflow-hidden">
                    <!-- Background Gradient -->
                    <div
                      class="absolute inset-0 bg-gradient-to-br from-gray-50 to-blue-50 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    ></div>

                    <!-- Club Image with Enhanced Hover Effect -->
                    <div
                      class="relative w-80 h-48 rounded-xl overflow-hidden shadow-lg group-hover:shadow-xl transition-all duration-500"
                    >
                      <img
                        :src="club.image"
                        :alt="club.name"
                        class="w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-110 filter grayscale"
                      />
                      <div
                        class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                      ></div>
                    </div>

                    <!-- Club Details with Enhanced Animations -->
                    <div class="flex-1 ml-8 relative z-10">
                      <div class="flex flex-col h-full">
                        <!-- Enhanced Categories -->
                        <div class="flex gap-3 mb-2">
                          <span
                            v-if="club.category_id"
                            class="px-4 py-1.5 rounded-full text-sm font-medium transition-all duration-300 transform hover:scale-105 hover:shadow-lg bg-blue-100 text-blue-800"
                          >
                            {{
                              categoryStore.getCategoryName(club.category_id)
                            }}
                          </span>
                        </div>

                        <!-- Enhanced Club Name -->
                        <h3
                          class="text-2xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent transform group-hover:scale-105 transition-transform duration-300 truncate"
                        >
                          {{ club.name }}
                        </h3>

                        <!-- Enhanced Description -->
                        <p
                          class="text-gray-600 text-lg leading-relaxed opacity-90 group-hover:opacity-100 transition-all duration-300 mb-6 line-clamp-2"
                        >
                          {{ club.description }}
                        </p>

                        <!-- Enhanced Action Button -->
                        <div class="flex items-center space-x-3">
                          <router-link
                            :to="`/club/${club.id}/dashboard`"
                            class="group px-6 py-3 bg-gradient-to-r from-primary to-accent text-white rounded-lg shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 relative overflow-hidden"
                          >
                            <div
                              class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"
                            ></div>
                            <span class="relative z-10 font-medium"
                              >Quản lý</span
                            >
                          </router-link>
                          <button
                            class="p-3 text-gray-400 hover:text-primary rounded-full hover:bg-gray-50 transition-all duration-300 transform hover:scale-110"
                          >
                            <MoreVerticalIcon class="h-6 w-6" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create Club Dialog -->
    <TransitionRoot appear :show="isCreateDialogOpen" as="template">
      <Dialog as="div" @close="closeCreateDialog" class="relative z-50">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel
                class="relative w-full max-w-4xl transform overflow-hidden rounded-2xl bg-white p-8 shadow-xl transition-all"
              >
                <!-- Decorative Elements -->
                <div
                  class="absolute -left-16 -top-16 w-48 h-48 bg-primary/10 rounded-full blur-3xl animate-pulse-slow"
                ></div>
                <div
                  class="absolute -right-16 -bottom-16 w-48 h-48 bg-accent/10 rounded-full blur-3xl animate-pulse-slow"
                ></div>

                <!-- Left Floating Elements -->
                <div class="absolute left-6 top-1/4 animate-float-slow">
                  <div
                    class="w-10 h-10 rounded-lg bg-gradient-to-r from-primary/20 to-primary/30 transform rotate-45"
                  ></div>
                </div>
                <div class="absolute left-12 bottom-1/4 animate-float-delayed">
                  <div
                    class="w-8 h-8 rounded-full bg-gradient-to-r from-accent/20 to-accent/30"
                  ></div>
                </div>

                <!-- Right Floating Elements -->
                <div class="absolute right-6 top-1/3 animate-float-delayed">
                  <div
                    class="w-8 h-8 rounded-full bg-gradient-to-r from-primary/20 to-primary/30"
                  ></div>
                </div>
                <div class="absolute right-12 bottom-1/3 animate-float-slow">
                  <div
                    class="w-10 h-10 rounded-lg bg-gradient-to-r from-accent/20 to-accent/30 transform -rotate-45"
                  ></div>
                </div>

                <!-- Content -->
                <div class="relative">
                  <!-- Header -->
                  <div class="flex justify-between items-center mb-8">
                    <DialogTitle
                      as="h3"
                      class="text-3xl font-bold text-gray-900 bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent"
                    >
                      Tạo Câu Lạc Bộ
                    </DialogTitle>
                    <button
                      @click="closeCreateDialog"
                      class="text-gray-400 hover:text-gray-500 transition-colors"
                    >
                      <XIcon class="h-8 w-8" />
                    </button>
                  </div>

                  <!-- Main Content -->
                  <div class="grid md:grid-cols-5 gap-12">
                    <!-- Left Illustration -->
                    <div class="md:col-span-2 flex items-center justify-center">
                      <div class="relative">
                        <img
                          src="../assets/achievements.webp"
                          alt="Create Club"
                          class="w-full max-w-[280px] animate-float"
                        />
                        <div
                          class="absolute inset-0 bg-gradient-to-t from-white via-transparent to-transparent"
                        ></div>
                      </div>
                    </div>

                    <!-- Form -->
                    <div class="md:col-span-3">
                      <form
                        @submit.prevent="handleCreateClub"
                        class="space-y-6"
                      >
                        <div class="space-y-5">
                          <div>
                            <label
                              class="block text-base font-medium text-gray-700 mb-2"
                            >
                              Tên Câu Lạc Bộ
                            </label>
                            <input
                              type="text"
                              v-model="newClub.name"
                              placeholder="Nhập tên đầy đủ"
                              class="w-full px-4 py-3 text-lg border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-300"
                              required
                            />
                          </div>

                          <div>
                            <label
                              class="block text-base font-medium text-gray-700 mb-2"
                            >
                              Email liên hệ
                            </label>
                            <input
                              type="email"
                              v-model="newClub.email"
                              placeholder="Nhập Email"
                              class="w-full px-4 py-3 text-lg border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-300"
                              required
                            />
                            <div class="mt-2">
                              <label class="inline-flex items-center">
                                <input
                                  type="checkbox"
                                  v-model="useCurrentEmail"
                                  class="form-checkbox h-5 w-5 text-primary rounded transition-all duration-300"
                                />
                                <span class="ml-2 text-sm text-blue-500"
                                  >Sử dụng email của tôi</span
                                >
                              </label>
                            </div>
                          </div>

                          <div>
                            <label
                              class="block text-base font-medium text-gray-700 mb-2"
                            >
                              Số điện thoại liên hệ
                            </label>
                            <input
                              type="tel"
                              v-model="newClub.phone"
                              placeholder="Nhập số điện thoại"
                              class="w-full px-4 py-3 text-lg border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-300"
                              required
                            />
                            <div class="mt-2">
                              <label class="inline-flex items-center">
                                <input
                                  type="checkbox"
                                  v-model="useCurrentPhone"
                                  class="form-checkbox h-5 w-5 text-primary rounded transition-all duration-300"
                                />
                                <span class="ml-2 text-sm text-blue-500"
                                  >Sử dụng số điện thoại của tôi</span
                                >
                              </label>
                            </div>
                          </div>

                          <div>
                            <label
                              class="block text-base font-medium text-gray-700 mb-2"
                            >
                              Thể loại câu lạc bộ
                            </label>
                            <select
                              v-model="newClub.category_id"
                              class="w-full px-4 py-3 text-lg border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-300"
                              required
                            >
                              <option value="" disabled selected>
                                Chọn thể loại
                              </option>
                              <option
                                v-for="category in categories"
                                :key="category.id"
                                :value="category.id"
                              >
                                {{ category.name }}
                                <span
                                  v-if="category.description"
                                  class="text-gray-500"
                                >
                                  - {{ category.description }}
                                </span>
                              </option>
                            </select>
                          </div>
                        </div>

                        <button
                          type="submit"
                          :disabled="loading"
                          class="w-full px-6 py-4 mt-6 text-lg font-medium text-white bg-gradient-to-r from-primary to-accent rounded-md shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all duration-300 relative overflow-hidden group disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          <span class="relative z-10">
                            {{ loading ? "Đang tạo..." : "Tạo Câu Lạc Bộ" }}
                          </span>
                          <div
                            class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"
                          ></div>
                        </button>
                      </form>
                    </div>
                  </div>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { storeToRefs } from "pinia";
import {
  BellIcon,
  UserCircleIcon,
  PlusIcon,
  MoreVerticalIcon,
  XIcon,
  UserIcon,
  MapPinIcon,
} from "lucide-vue-next";
import { useAuthStore } from "../stores/authStore";
import { useCategoryStore } from "../stores/categoryStore";
import { useClubStore } from "../stores/clubStore";
import { useJoinRequestStore } from "../stores/joinRequestStore";
import AOS from "aos";
import {
  Dialog,
  DialogPanel,
  DialogTitle,
  TransitionRoot,
  TransitionChild,
} from "@headlessui/vue";

const authStore = useAuthStore();
const categoryStore = useCategoryStore();
const clubStore = useClubStore();
const joinRequestStore = useJoinRequestStore();
const { user } = storeToRefs(authStore);
const userClubs = ref([]);
const loading = ref(false);
const error = ref(null);
const categories = computed(() =>
  categoryStore.clubCategories.filter((category) => category.type === "club")
);
const isCreateDialogOpen = ref(false);
const useCurrentEmail = ref(false);
const useCurrentPhone = ref(false);

const newClub = ref({
  name: "",
  email: "",
  phone: "",
  category_id: "",
  user_id: authStore.user?.id,
});

const fetchUserClubs = async () => {
  try {
    loading.value = true;
    error.value = null;
    if (user.value?.id) {
      await clubStore.fetchUserClubs(user.value.id);
      return clubStore.clubs.map((club) => ({
        ...club,
        image:
          club.background_images?.[0]?.image_url || "/default-club-image.jpg",
        tags: [club.category?.name || "Chưa phân loại"],
        description: club.description || "Chưa có mô tả",
      }));
    }
    return [];
  } catch (err) {
    console.error("Error fetching user clubs:", err);
    error.value = "Không thể tải danh sách câu lạc bộ";
    return [];
  }
};

const fetchJoinUserClubs = async () => {
  try {
    loading.value = true;
    error.value = null;
    if (user.value?.id) {
      const userClubsData = await joinRequestStore.getUserClubs(user.value.id);
      return userClubsData.map((club) => ({
        ...club,
        image:
          club.background_images?.[0]?.image_url || "/default-club-image.jpg",
        tags: [club.category?.name || "Chưa phân loại"],
        description: club.description || "Chưa có mô tả",
      }));
    }
    return [];
  } catch (err) {
    console.error("Error fetching joined clubs:", err);
    error.value = "Không thể tải danh sách câu lạc bộ đã tham gia";
    return [];
  }
};

const loadAllClubs = async () => {
  try {
    loading.value = true;
    error.value = null;

    // Fetch both created and joined clubs
    const [createdClubs, joinedClubs] = await Promise.all([
      fetchUserClubs(),
      fetchJoinUserClubs(),
    ]);

    // Combine and remove duplicates based on club ID
    const uniqueClubs = [...createdClubs, ...joinedClubs].reduce(
      (acc, club) => {
        if (!acc.find((c) => c.id === club.id)) {
          acc.push(club);
        }
        return acc;
      },
      []
    );

    userClubs.value = uniqueClubs;
  } catch (err) {
    console.error("Error loading all clubs:", err);
    error.value = "Không thể tải danh sách câu lạc bộ";
  } finally {
    loading.value = false;
  }
};

// Update onMounted to use the new function
onMounted(async () => {
  try {
    await categoryStore.fetchCategories();
    await loadAllClubs();
    AOS.refresh();
  } catch (error) {
    console.error("Error initializing:", error);
  }
});

const openCreateDialog = () => {
  isCreateDialogOpen.value = true;
  if (useCurrentEmail.value) {
    newClub.value.email = authStore.user?.email || "";
  }
  // Set user_id when opening dialog
  newClub.value.user_id = authStore.user?.id;
};

const closeCreateDialog = () => {
  isCreateDialogOpen.value = false;
  // Reset form
  newClub.value = {
    name: "",
    email: "",
    phone: "",
    category_id: "",
    user_id: authStore.user?.id,
  };
  useCurrentEmail.value = false;
  useCurrentPhone.value = false;
};

watch(useCurrentEmail, (newValue) => {
  if (newValue) {
    newClub.value.email = authStore.user?.email || "";
  } else {
    newClub.value.email = "";
  }
});

watch(useCurrentPhone, (newValue) => {
  if (newValue) {
    newClub.value.phone = authStore.user?.phone || "";
  } else {
    newClub.value.phone = "";
  }
});

const handleCreateClub = async () => {
  try {
    loading.value = true;
    error.value = null;

    // Ensure user is logged in
    if (!newClub.value.user_id) {
      throw new Error("Bạn cần đăng nhập để tạo câu lạc bộ");
    }

    // Create the club
    const response = await clubStore.createClub({
      name: newClub.value.name,
      contact_email: newClub.value.email,
      contact_phone: newClub.value.phone,
      category_id: parseInt(newClub.value.category_id),
      user_id: newClub.value.user_id,
    });

    // Refresh the clubs list
    await loadAllClubs();

    // Show success message (you might want to add a toast notification here)
    console.log("Club created successfully:", response);

    // Close the dialog
    closeCreateDialog();
  } catch (error) {
    console.error("Error creating club:", error);
    error.value = error.message || "Có lỗi xảy ra khi tạo câu lạc bộ";
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.container {
  max-width: 1280px;
}

/* Enhanced Animations */
@keyframes blob {
  0%,
  100% {
    transform: translate(0, 0) scale(1);
  }
  25% {
    transform: translate(20px, -20px) scale(1.1);
  }
  50% {
    transform: translate(0, 20px) scale(1);
  }
  75% {
    transform: translate(-20px, -20px) scale(0.9);
  }
}

.animate-blob {
  animation: blob 10s infinite;
}

.animation-delay-2000 {
  animation-delay: 2s;
}

.animation-delay-4000 {
  animation-delay: 4s;
}

@keyframes gradient {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

.animate-gradient {
  background-size: 200% auto;
  animation: gradient 4s linear infinite;
}

/* Enhanced Hover Effects */
.hover-lift {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.hover-lift:hover {
  transform: translateY(-5px);
}

/* Enhanced Card Styles */
.card-shadow {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: box-shadow 0.3s ease-in-out;
}

.card-shadow:hover {
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1),
    0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

/* Enhanced Tag Colors */
.tag-academic {
  @apply bg-gradient-to-r from-green-100 to-emerald-100 text-green-800;
}

.tag-art {
  @apply bg-gradient-to-r from-purple-100 to-pink-100 text-purple-800;
}

.tag-admin {
  @apply bg-gradient-to-r from-blue-100 to-indigo-100 text-blue-800;
}

/* Smooth Scrolling */
html {
  scroll-behavior: smooth;
}

/* Custom Scrollbar */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background: linear-gradient(to bottom, var(--primary), var(--accent));
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(to bottom, var(--accent), var(--primary));
}
</style>
