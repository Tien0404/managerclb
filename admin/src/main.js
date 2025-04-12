import { createApp } from 'vue';
import App from './App.vue';
import { createPinia } from 'pinia';
import VueAxios from 'vue-axios';
import axios from 'axios';

const pinia = createPinia();
const app = createApp(App);
app.use(pinia);

app.use(VueAxios, axios);

app.mount('#app');