import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './style.css'

// Animation libraries
import AOS from 'aos'
import 'aos/dist/aos.css'
import Vue3Lottie from 'vue3-lottie'
import 'vue3-loading-overlay/dist/vue3-loading-overlay.css'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

// Toast notification
import { toast } from './plugins/toast'

// Initialize AOS
AOS.init({
  duration: 800,
  easing: 'ease-in-out',
  once: true
})

// Configure NProgress
NProgress.configure({ 
  showSpinner: false,
  trickleSpeed: 200
})

// Router navigation guards for loading bar
router.beforeEach((to, from, next) => {
  NProgress.start()
  next()
})

router.afterEach(() => {
  NProgress.done()
})

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(Vue3Lottie)
app.use(toast)

app.mount('#app')

