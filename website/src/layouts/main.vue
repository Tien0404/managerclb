<template>
    <div id="app" class="flex flex-col h-screen">

        <!-- Main Content -->
        <div class="flex-1 flex flex-col">
            <div class="fixed top-0 left-0 w-full z-50 bg-white/90 backdrop-blur-sm shadow-lg">
                <Header />
            </div>
            <div class="flex-1 overflow-y-auto pt-16">
                <router-view />
            </div>
        </div>

        <!-- Footer -->
        <Footer />
    </div>
</template>

<script>
import Header from "../components/Header.vue";
import Footer from "../components/Footer.vue";

export default {
    components: {
        Header,
        Footer,
    },
};
</script>

<style>
/* Optional: Add styling for header height consistency */
.shadow-lg {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
                0 2px 4px -1px rgba(0, 0, 0, 0.06);
}
</style>
