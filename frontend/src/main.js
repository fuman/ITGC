import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

// DevExtreme
import 'devextreme/dist/css/dx.light.css'
import config from 'devextreme/core/config'

// Global styles
import './assets/css/global.scss'

// DevExtreme 전역 설정
config({
  defaultCurrency: 'KRW',
  defaultUseMaskBehavior: true,
  licenseKey: '' // 개발 환경
})

// DevExtreme locale
import koMessages from 'devextreme/localization/messages/ko.json'
import { locale, loadMessages } from 'devextreme/localization'

loadMessages(koMessages)
locale('ko')

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

app.mount('#app')
