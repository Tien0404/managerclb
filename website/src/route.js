
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  {
    path: '/',
    name: 'Dashboard',
  },

];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;