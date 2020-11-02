<template>
  <div id="app">
    <HeaderComponent/>
    <main class="content">
      <router-view />
    </main>
    <FooterComponent/>
  </div>
</template>

<script>
import FooterComponent from "./components/Footer"
import HeaderComponent from "./components/Header"
export default {
  components: {
    FooterComponent,
    HeaderComponent
  }
};
</script>
