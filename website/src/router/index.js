import { createWebHistory, createRouter } from 'vue-router'

import Club from './club'
import Main from './main'
import Profile from './Profile';

const routes = [...Club, ...Main, ...Profile];

const router = createRouter({
    history: createWebHistory(),
    routes,
})

export default router;