import Profile from "../layouts/Profile.vue";
import ProfilePage from "../pages/Profile.vue";
import HistoryEvent from "../pages/HistoryEvent.vue"
const main = [
    {
        path: "/profile",
        component: Profile,
        children: [
            {
                path: "",
                name: "profile",
                component: ProfilePage,
            },
            {
                path: "historyEvent",
                name: "historyEvent",
                component: HistoryEvent,
            },
        ]
    }
]

export default main;