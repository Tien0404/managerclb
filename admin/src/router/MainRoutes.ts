const MainRoutes = {
    path: '/main',
    meta: {
        requiresAuth: true
    },
    redirect: '/main',
    component: () => import('@/layouts/full/FullLayout.vue'),
    children: [
        {
            name: 'Dashboard',
            path: '/',
            component: () => import('@/views/dashboard/index.vue')
        },
        {
            name: 'UserManagement',
            path: '/user-management-page',
            component: () => import('@/views/pages/UserManagement.vue')
        },
        {
            name: 'CategoryManagement',
            path: '/category-management-page',
            component: () => import('@/views/pages/CategoryManagement.vue')
        },
        {
            name: 'CLBManagement',
            path: '/clb-management-page',
            component: () => import('@/views/pages/CLBManagement.vue')
        },
        {
            name: 'EventManagement',
            path: '/event-management-page',
            component: () => import('@/views/pages/EventManagement.vue')
        },
        {
            name: 'FeedbackManagement',
            path: '/feedback-management-page',
            component: () => import('@/views/pages/FeedbackManagement.vue')
        },
        {
            name: 'BlogManagement',
            path: '/blog-management-page',
            component: () => import('@/views/pages/BlogManagement.vue')
        },
    ]
};

export default MainRoutes;
