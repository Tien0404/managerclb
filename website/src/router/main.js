import MainLayout from "../layouts/main.vue";
import Home from "../pages/home.vue";
import Event from "../pages/EventPage.vue";
import EventList from "../pages/EventListPage.vue";
import Club from "../pages/ClubPage.vue";
import MyClub from "../pages/ClubManagement.vue";
import Blog from "../pages/BlogListPage.vue";
import Login from "../pages/Login.vue";
import Register from "../pages/Register.vue";
import EmailVerification from "../components/Register/EmailVerification.vue";
import ForgotPassword from "../pages/ForgotPassword.vue";
import ResetPassword from "../pages/ResetPassword.vue";
import NotificationsPage from "../pages/NotificationsPage.vue";

const main = [
  {
    path: "/",
    component: MainLayout,
    children: [
      {
        path: "",
        component: Home,
      },
      {
        path: "event/:id",
        component: Event,
      },
      {
        path: "clb/:id",
        component: Club,
      },
      {
        path: "blog-list-page",
        component: Blog,
      },
      {
        path: "event",
        component: EventList,
      },
      {
        path: "manage-club-page",
        component: MyClub,
      },
      {
        path: "login",
        component: Login,
      },
      {
        path: "register",
        component: Register,
      },
      {
        path: "email-verification",
        component: EmailVerification,
        props: true,
      },
      {
        path: "forgot-password",
        component: ForgotPassword,
      },
      {
        path: "reset-password",
        component: ResetPassword,
      },
      {
        path: "notifications",
        component: NotificationsPage,
      },
    ],
  },
];

export default main;
