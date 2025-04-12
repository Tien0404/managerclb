<template>
    <div id="app" class="flex flex-col h-screen">
        <div class="fixed top-0 left-0 w-full z-50 bg-white/90 backdrop-blur-sm shadow-lg">
                <Header />
            </div>
        <div class="flex flex-1 mt-16">
            <div class="fixed top-16 left-0 w-64 bg-white shadow-lg z-10">
                <Menu />
            </div>
            <div class="content ml-64 flex-1 overflow-y-auto bg-gray-50">
                <router-view />
            </div>
        </div>
    </div>
</template>

<script>
import Header from "../components/Header.vue";
import Menu from "../components/Profile/Menu.vue";

export default {
    components: {
        Header,
        Menu,
    },
};
</script>
