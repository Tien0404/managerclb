import { createRouter, createWebHistory } from 'vue-router';
import MainRoutes from './MainRoutes';
import AuthRoutes from './AuthRoutes';

export const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/:pathMatch(.*)*',
            component: () => import('@/views/auth/Error.vue')
        },
        MainRoutes,
        AuthRoutes
    ]
});
router.beforeEach((to, from, next) => {
    const token = localStorage.getItem('authToken');
    if (to.matched.some(record => record.meta.requiresAuth) && !token) {
        next('/auth/login'); // Chuyển đến trang đăng nhập nếu không có token
    } else {
        next(); // Tiếp tục đến route yêu cầu
    }
});
