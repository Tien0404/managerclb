
export interface menu {
    header?: string;
    title?: string;
    icon?: any;
    to?: string;
    chip?: string;
    BgColor?: string;
    chipBgColor?: string;
    chipColor?: string;
    chipVariant?: string;
    chipIcon?: string;
    children?: menu[];
    disabled?: boolean;
    type?: string;
    subCaption?: string;
}

const sidebarItem: menu[] = [
    { header: 'Home' },
    {
        title: 'Dashboard',
        icon: 'widget-add-line-duotone',
        to: '/'
    },
    { header: 'Management' },
    {
        title: 'User Management',
        icon: 'hamburger-menu-outline',
        to: '/user-management-page'
    },
    {
        title: 'Category Management',
        icon: 'hamburger-menu-outline',
        to: '/category-management-page'
    },
    {
        title: 'CLB Management',
        icon: 'hamburger-menu-outline',
        to: '/clb-management-page'
    },
    {
        title: 'Event Management',
        icon: 'hamburger-menu-outline',
        to: '/event-management-page'
    },
    {
        title: 'Feedback Management',
        icon: 'hamburger-menu-outline',
        to: '/feedback-management-page'
    },
    {
        title: 'Blog Management',
        icon: 'hamburger-menu-outline',
        to: '/blog-management-page'
    },
    { header: 'auth' },
    {
        title: 'Login',
        icon: 'login-3-line-duotone',
        to: '/auth/login'
    },
];

export default sidebarItem;

