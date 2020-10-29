<template>
  <div id="app">
    <Layout>
      <HHeader>
        <div id="nav">
          <router-link to="/">Home</router-link> |
          <router-link to="/about">About</router-link>
        </div></HHeader
      >
      <Content><router-view /></Content>
      <HFooter>Footer</HFooter>
    </Layout>
  </div>
</template>

