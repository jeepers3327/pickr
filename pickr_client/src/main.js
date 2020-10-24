import Vue from 'vue'
import HeyUI from "heyui"
import App from './App.vue'
import router from './router'
import "heyui/themes/index.less";
import en from 'heyui/dist/locale/en-US';

import {Socket} from "./channels/index";

Vue.config.productionTip = false

Vue.use(HeyUI, {locale: en});

Socket.connect();

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
