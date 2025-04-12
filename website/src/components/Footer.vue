<template>
    <footer class="bg-gray-50 text-black shadow-md">
        <div class="container mx-auto px-6 py-6">
            <!-- Footer Content -->
            <div class="flex flex-col md:flex-row justify-between items-center space-y-6 md:space-y-0">
                <!-- Logo / Website Name -->
                <div class="text-center md:text-left">
                    <h1 class="text-2xl font-bold" style="color: #B3995D">VAA CLUB</h1>
                    <p class="text-sm text-gray-400">Bringing you the best since 2024</p>
                </div>

                <!-- Quick Links -->
                <div class="flex space-x-6">
                    <a href="#" class="text-gray-400 hover:text-blue-400">About</a>
                    <a href="#" class="text-gray-400 hover:text-blue-400">Services</a>
                    <a href="#" class="text-gray-400 hover:text-blue-400">Contact</a>
                    <a href="#" class="text-gray-400 hover:text-blue-400">Privacy</a>
                </div>

                <!-- Copyright -->
                <div class="text-center md:text-right">
                    <span class="text-sm text-gray-400">&copy; 2024 VAA.</span>
                </div>
            </div>

            <!-- Social Icons -->
            <div class="mt-6 flex justify-center space-x-4">
                <a href="#" class="text-gray-400 hover:text-blue-400">
                    <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24">
                        <path
                            d="M24 4.56v14.91c0 .93-.76 1.68-1.68 1.68h-20.64c-.92 0-1.68-.75-1.68-1.68v-14.91c0-.92.76-1.68 1.68-1.68h20.64c.92 0 1.68.76 1.68 1.68zm-10.8 2.88h-3.2c-1.77 0-3.2 1.43-3.2 3.2v3.2h-2.88v3.2h2.88v9.6h3.2v-9.6h2.88v-3.2h-2.88v-2.4c0-.88.72-1.6 1.6-1.6h1.6v-3.2z" />
                    </svg>
                </a>
                <a href="#" class="text-gray-400 hover:text-blue-400">
                    <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24">
                        <path
                            d="M12 2.2c-5.42 0-9.8 4.38-9.8 9.8 0 4.83 3.58 8.82 8.23 9.63v-6.81h-2.48v-2.8h2.48v-1.92c0-2.48 1.47-3.88 3.73-3.88 1.08 0 2.21.2 2.21.2v2.43h-1.25c-1.23 0-1.62.76-1.62 1.54v1.62h2.75l-.44 2.8h-2.31v6.81c4.65-.81 8.23-4.8 8.23-9.63 0-5.42-4.38-9.8-9.8-9.8z" />
                    </svg>
                </a>
                <a href="#" class="text-gray-400 hover:text-blue-400">
                    <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24">
                        <path
                            d="M21.94 4.19c-.77.35-1.59.59-2.45.69.88-.52 1.55-1.35 1.87-2.34-.82.49-1.73.85-2.7 1.05-.78-.83-1.89-1.35-3.12-1.35-2.36 0-4.28 1.92-4.28 4.28 0 .34.04.67.11.99-3.56-.18-6.72-1.88-8.83-4.47-.37.63-.59 1.36-.59 2.14 0 1.48.76 2.79 1.92 3.55-.71-.02-1.37-.22-1.95-.54v.05c0 2.07 1.47 3.8 3.42 4.2-.36.1-.75.15-1.14.15-.28 0-.55-.03-.81-.08.56 1.75 2.17 3.03 4.09 3.07-1.49 1.17-3.37 1.87-5.41 1.87-.35 0-.7-.02-1.04-.06 1.93 1.24 4.23 1.96 6.7 1.96 8.04 0 12.45-6.66 12.45-12.45 0-.19 0-.39-.01-.58.85-.61 1.59-1.37 2.18-2.24z" />
                    </svg>
                </a>
            </div>
        </div>
    </footer>
</template>

<script>
export default {
    name: "FooterComponent",
};
</script>