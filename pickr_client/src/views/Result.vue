<template>
  <div>test result {{poll.id}} 
     <div v-width="500" v-if="poll">
          <div v-for="(option,index) of poll.options" :key="option.id">
           <p><Progress :percent="option.votes" :strokeWidth="15" :color="colors[index]">
            <span slot="title">{{option.value}}</span>
           <span slot="text"><span class="red-color">{{option.votes}}%</span></span>
           </Progress></p>
      </div>
     </div>
  </div>
</template>

<script>

import {  fetchPollResult } from "../services/poll"

import {Socket} from "../channels/index"

export default {
    data() {
        return {
            poll: {},
            colors: [
                "#9E7BFF", "#461B7E", "#E4287C", 
                "#800517", "#F62217", "#FF7F50", 
                "#C36241", "#EE9A4D", "#FBB917", 
                "#FFF380", "#6AFB92", "#9DC209", 
                "#306754", "#008080", "#92C7C7", 
                "#9AFEFF", "#3BB9FF", "#2B65EC", 
                "#2B3856", "#657383", "#736AFF"
                ],
            channel: null
        }
    },

    beforeRouteEnter(to, from, next) {
        fetchPollResult(to.params.id)
            .then(response => {
                next(vm => {
                    vm.poll = response;
                });
             }).catch(() => {
                 next('/404')
             });
    },
    
    mounted() {
       Socket.findChannel(this.poll.id)
        .then(({channel}) => {
            this.channel = channel;
            this.channel.on("updated_result", response => {
                this.poll = response;
            })
        });
    }
}
</script>

<style>

</style>