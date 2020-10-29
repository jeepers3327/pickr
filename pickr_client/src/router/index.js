import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import(/* webpackChunkName: "create_poll" */ '../views/CreatePoll.vue')
  },
  {
    path: '/poll',
    name: 'Create Poll',
    component: () => import(/* webpackChunkName: "create_poll" */ '../views/CreatePoll.vue')
  },
  {
    path: '/poll/:id',
    name: 'Poll',
    component: () => import(/* webpackChunkName: "poll" */ '../views/Poll.vue')
  },
  {
    path: '/poll/:id/result',
    name: 'Result',
    component: () => import(/* webpackChunkName: "result" */ '../views/Result.vue')
  },
  {
    path: '*',
    name: 'Error',
    component: () => import(/* webpackChunkName: "error" */ '../views/Error.vue')
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
