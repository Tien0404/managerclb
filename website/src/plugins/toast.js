import { createApp } from 'vue'
import Toast, { useToast } from 'vue-toastification'
import 'vue-toastification/dist/index.css'

// Toast Default Options
const options = {
    position: 'top-right',
    timeout: 3000,
    closeOnClick: true,
    pauseOnFocusLoss: true,
    pauseOnHover: true,
    draggable: true,
    draggablePercent: 0.6,
    showCloseButtonOnHover: false,
    hideProgressBar: true,
    closeButton: 'button',
    icon: true,
    rtl: false,
    transition: 'Vue-Toastification__bounce',
    maxToasts: 5,
    newestOnTop: true,
    filterBeforeCreate: (toast, toasts) => {
        if (toasts.filter(t => t.type === toast.type).length !== 0) {
            // Returning false discards the toast
            return false
        }
        // You can modify the toast if you want
        return toast
    },
    toastDefaults: {
        // ToastOptions object for each type of toast
        success: {
            timeout: 2000,
            icon: {
                iconClass: 'toast-success-icon',
                iconChildren: '✓',
                iconTag: 'div'
            }
        },
        error: {
            timeout: 4000,
            icon: {
                iconClass: 'toast-error-icon',
                iconChildren: '✕',
                iconTag: 'div'
            }
        },
        warning: {
            timeout: 3000,
            icon: {
                iconClass: 'toast-warning-icon',
                iconChildren: '!',
                iconTag: 'div'
            }
        },
        info: {
            timeout: 3000,
            icon: {
                iconClass: 'toast-info-icon',
                iconChildren: 'i',
                iconTag: 'div'
            }
        }
    }
}

// Create toast plugin
export const toast = useToast()

// Export Vue plugin
export default {
    install: (app) => {
        app.use(Toast, options)
    }
}