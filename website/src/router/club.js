import ClubManageLayout from "../layouts/ClubManage.vue";
import Dashboard from "../pages/ClubManage/Dashboard.vue";
import InfoClub from "../pages/ClubManage/ClubInfo.vue";
import Introduce from "../pages/ClubManage/Introduce.vue";
import Event from "../pages/ClubManage/Event.vue";
import Member from "../pages/ClubManage/Member.vue";
import Blog from "../pages/ClubManage/Blog.vue";
import UserEvent from "../pages/ClubManage/UserEvent.vue";
import JoinReq from "../pages/ClubManage/JoinReq.vue";
import Feedback from "../pages/ClubManage/ResponseManagePage.vue";

const admin = [
  {
    path: "/club",
    component: ClubManageLayout,
    children: [
      {
        path: ":id/dashboard",
        name: "dashboard",
        component: Dashboard,
      },
      {
        path: ":id/update-info-club",
        name: "update-info-club",
        component: InfoClub,
      },
      {
        path: ":id/quan-ly-trang-dai-dien",
        name: "quan-ly-trang-dai-dien",
        component: Introduce,
      },
      {
        path: ":id/quan-ly-thanh-vien",
        name: "quan-ly-thanh-vien",
        component: Member,
      },
      {
        path: ":id/quan-ly-su-kien",
        name: "quan-ly-su-kien",
        component: Event,
      },
      {
        path: ":id/quan-ly-blog",
        name: "quan-ly-blog",
        component: Blog,
      },
      {
        path: ":id/quan-ly-phan-hoi",
        name: "quan-ly-phan-hoi",
        component: Feedback,
      },
    ],
  },
  {
    path: "/event/:id/users",
    name: "EventUsers",
    component: UserEvent,
  },
  {
    path: "/club/:id/danh-sach-cho",
    name: "JoinReq",
    component: JoinReq,
  },
];

export default admin;
