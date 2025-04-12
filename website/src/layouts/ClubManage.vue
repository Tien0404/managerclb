<template>
    <div id="app" class="flex h-screen">
        <Menu />
        <div class="content ml-64 flex-1 overflow-y-auto">
            <router-view />
        </div>
    </div>
</template>

<script>
import Menu from "../components/Menu.vue";

export default {
    components: {
        Menu,
    },
};
</script>